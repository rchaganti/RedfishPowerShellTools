function Get-RedfishSystemStorage
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.Storage)
    {
        return $ConnectionObject.Systems.Storage
    }
    else
    {
        throw 'Connection Object does not contain Storage key under Systems.'    
    }
}
