function Get-RedfishSystemBIOSAttributeRegistry
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    #Get the session from ConnectionObject
    $header = $ConnectionObject.Token
    if (!$header.Accept)
    {
        $header.Add('Accept','application/json')
    }
    $IPAddress = $header.IPAddress
    
    #Get the registry Uri from Connection Object
    $registryLocation = $ConnectionObject.Registries.Where({$_.Id -eq $ConnectionObject.Systems.Bios.AttributeRegistry}).Location.Uri
    $registryUri = "https://${IPAddress}${registryLocation}"
    
    #Perform request and gather registry entries
    $biosRegistry = Invoke-RestMethod -Uri $registryUri -Method Get -UseBasicParsing -Headers $header -ContentType 'application/json'
    return $biosRegistry.RegistryEntries.Attributes
}
