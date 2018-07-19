Function Export-RedfishSystemConfigurationProfile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,
    
        [Parameter()]
        [String]
        $FilePath
    )
    
    #Get the session from ConnectionObject
    $header = $ConnectionObject.Token
    if (!$header.Accept)
    {
        $header.Add('Accept','application/json')
    }
    
    $ipAddress = $header.IPAddress
    
    $requestParameters = @{
        'ExportFormat'    = 'JSON'
        'ShareParameters' = @{'Target'='All'}
    }
    
    $requestBody = $requestParameters | ConvertTo-Json
    
    $url = "https://${ipAddress}/redfish/v1/Managers/iDRAC.Embedded.1/Actions/Oem/EID_674_Manager.ExportSystemConfiguration"
    $response = Invoke-WebRequest -Uri $url -Headers $header -Method Post -Body $requestBody -ContentType 'application/json' -Verbose -ErrorAction SilentlyContinue
    
    if ($response)
    {
        if ($response.StatusCode -match "200|202|204")
        {
            $taskEndpoint = $response.Headers.Location
    
            #Retrieve the JOB ID
            $taskId = Split-Path -Path $taskEndpoint -Leaf
    
            #wait for task
            $completedTask = Get-RedfishSystemTask -ConnectionObject $ConnectionObject -TaskId $taskId -Wait
            $scpJson = $completedTask.Content
            if ($FilePath)
            {
                Out-File -FilePath $FilePath -InputObject $scpJson -Encoding utf8 -Force
            }
            else
            {
                return ($scpJson | ConvertFrom-Json)
            }
        }
    }
}
