function Get-RedfishSystemLCLogEntry
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Managers.LogServices)
    {
        return $ConnectionObject.Managers.LogServices.Where({$_.Id -eq 'LC'}).Entries
    }
    else
    {
        throw 'ConnectionObject does not have a key by name LogServices under Managers.'    
    }
}
