function Mount-RedfishSystemConfigurationProfile
{
    [CmdletBinding(DefaultParameterSetName = 'ConnectionObject')]
    param
    (
        [Parameter(ParameterSetName = 'ConnectionObject', Mandatory = $true)]
        $ConnectionObject,

        [Parameter(ParameterSetName = 'ScpJson', Mandatory = $true)]
        $ScpJsonFile
    )

    #Create the drive if it does not exist
    if (-not (Get-PSDrive -Name SCP -ErrorAction SilentlyContinue))
    {
        $null = New-PSDrive -Name SCP -PSProvider SHiPS -Root 'RedfishPowerShellTools#ServerRoot' -Verbose -Scope Global
    }

    #if we have a reference JSON, we can mount that.
    if ($ScpJsonFile)
    {
        if (Test-Path -Path $ScpJsonFile)
        {
            $json = Get-Content -Path $ScpJsonFile -Raw | ConvertFrom-Json
            $serviceTag = $json.SystemConfiguration.ServiceTag
            if ($json -and (-not ($serviceTag)))
            {
                $serviceTag = (-join ((48..57) + (97..122) | Get-Random -Count 7 | ForEach-Object {[char]$_})).ToUpper()
                $json.SystemConfiguration | Add-Member -MemberType NoteProperty -Name ServiceTag -Value $serviceTag
            }
        }
        else
        {
            throw "$JsonPath not found."
        }
    }
    else
    {
        #Connect to the remote system
        $json = Export-RedfishSystemConfigurationProfile -ConnectionObject $ConnectionObject
        $firmwareInventory = Get-RedfishSystemFirmwareInventory -ConnectionObject $ConnectionObject

        #Only live systems will get firmware inventory
        $json | Add-Member -MemberType NoteProperty 'FirmwareInventory' -Value $firmwareInventory
    }

    $serviceTag = $json.SystemConfiguration.ServiceTag
    $json | Add-Member -MemberType NoteProperty 'IPAddress' -Value $ConnectionObject.Token.IPAddress

    if (-not ([ServerRoot]::availableServers | Where-Object {$_.SystemConfiguration.ServiceTag -eq $serviceTag}))
    {
        [ServerRoot]::availableServers += $json
    }

    return $serviceTag
}
