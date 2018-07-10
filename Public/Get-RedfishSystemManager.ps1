function Get-RedfishSystemManager
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Managers)
    {
        return $ConnectionObject.Managers
    }
    else
    {
        throw 'ConnectionObject does not have a key by name Managers.'    
    }
}
