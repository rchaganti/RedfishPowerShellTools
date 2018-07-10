function Get-RedfishSystemTrustedModule
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.TrustedModules)
    {
        return $ConnectionObject.Systems.TrustedModules
    }
    else
    {
        throw 'Connection Object does not contain TrustedModules key under Systems.'    
    }
}
