function Get-RedfishEndpointData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [String]
        $Endpoint,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential
    )

    $Url = "https://${IPAddress}${EndPoint}"
    Write-Verbose -Message "Processing ${EndPoint} ..."
    $response = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $Url -Credential $Credential
    
    #Remove links if present. Without this we may go into an endless recursion
    if ($response.Links)
    {
        $response.PSObject.Properties.Remove('Links')
    }

    #Remove meta-data such as oData Context and Id
    $response.PSObject.Properties.Remove('@odata.context')
    $response.PSObject.Properties.Remove('@odata.Id')

    #Property has instances
    if ($response.Members)
    {
        $memberResponse = @()
        foreach ($member in $response.Members)
        {
            $memberResponse += Get-RedfishEndpointData -IPAddress $IPAddress -Endpoint $member.'@odata.id' -Credential $Credential -ErrorAction SilentlyContinue
        }
            
        $response = $memberResponse
        #$response.Members = $memberResponse
        #$response.PSObject.Properties.Remove('Members@odata.count')
    }

    foreach ($property in $response.PSObject.Properties.Name)
    {        
        #This means we have a property with an oData ID. This could be a collection.
        if (($response.$property -is [PSCustomObject]) -and ($response.$property.PSObject.Properties.Count -eq 1) -and ($response.$Property.'@odata.id'))
        {
            $response.$property = Get-RedfishEndpointData -IPAddress $IPAddress -Endpoint $response.$property.'@odata.id' -Credential $Credential -ErrorAction SilentlyContinue
        }
    }

    return $response
}
