function Initialize-API
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [String]
        $IPAddress
    )

    $peJson = Get-Content -Path "$PSScriptRoot\peSystem.json" -Raw | ConvertFrom-Json
    $baseURI = "https://${IPAddress}$($peJson.baseURI)"

    $apiCollection = @{
        'BaseUri' = $baseURI
    }

    foreach ($property in $peJson.psobject.properties.name)
    {
        if ($property -ne 'baseURI')
        {
            $apiCollection.Add($property, "$baseURI$($peJson.$property)")
        }
    }

    return $apiCollection
}