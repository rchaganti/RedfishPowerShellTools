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
        return $ConnectionObject.Systems
    }
    else
    {
        throw 'ConnectionObject does not have a key by name Systems.'    
    }
}
