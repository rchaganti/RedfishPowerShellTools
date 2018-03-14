function New-DellEMCPERedfishSession
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential
    )

    $baseURI = (Initialize-API -IPAddress $IPAddress).baseUri
    if (Invoke-RestMethod -Uri $baseURI -ErrorAction SilentlyContinue)
    {
        
    }
    else
    {
        throw "$baseURI is an invalid Redfish Endpoint."    
    }
}
