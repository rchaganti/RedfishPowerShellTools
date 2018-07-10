function Get-RedfishSchema
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $IPAddress
    )

    $uri = "https://${IPAddress}/redfish/v1/JSONSchemas"
    $response = Invoke-RestMethod -Uri $uri -UseBasicParsing -Verbose
    $memberSchema = $response.Members.'@odata.id'

    $schemaArray = @()
    foreach ($schema in $memberSchema)
    {
        $schemaObject = [Ordered]@{}
        $schemaObject.psobject.TypeNames.Insert(0, 'Redfish.Schema')

        $memberObject = (Split-Path -Path $schema -Leaf).Split('.')
        $schemaObject.Add('Member',$memberObject[0])
        if ($memberObject[1])
        {
            $version = $memberObject[1].Replace('_','.')
        }
        else
        {
            $version = $null    
        }
        $schemaObject.Add('Version',$version)

        $schemaObject.Add('Uri',"https://${IPAddress}/redfish/v1/Schemas/$($memberObject -join '.').json")
        $schemaArray += $schemaObject
    }
    return $schemaArray
}
