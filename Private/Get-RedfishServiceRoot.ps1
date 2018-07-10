function Get-RedfishServiceRoot
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [String]
        $IPAddress
    )
    
    $baseURI = "https://${IPAddress}/redfish/v1"
    $response = Invoke-RestMethod -UseBasicParsing -Uri $baseURI
    return $response
}
