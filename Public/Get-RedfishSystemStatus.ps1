function Get-RedfishSystemStatus
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.Status)
    {
        return $ConnectionObject.Systems.Status
    }
    else
    {
        throw 'ConnectionObject does not have a key by name status under Systems.'    
    }
}

Status