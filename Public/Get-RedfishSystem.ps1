function Get-RedfishSystem
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems)
    {
        $systems = $ConnectionObject.Systems
        $systems.PSObject.TypeNames.Insert(0,"Redfish.System")

        return $systems
    }
    else
    {
        throw 'ConnectionObject does not have a key by name Systems.'
    }
}
