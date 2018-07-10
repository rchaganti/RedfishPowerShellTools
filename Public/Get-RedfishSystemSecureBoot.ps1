function Get-RedfishSystemSecureBoot
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.SecureBoot)
    {
        return $ConnectionObject.Systems.SecureBoot
    }
    else
    {
        throw 'Connection Object does not contain SecureBoot key under Systems.'    
    }
}
