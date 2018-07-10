function Get-RedfishSystemEthernetInterface
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.EthernetInterfaces)
    {
        return $ConnectionObject.Systems.EthernetInterfaces
    }
    else
    {
        throw 'Connection Object does not contain EthernetInterfaces key under Systems.'    
    }
}
