function Get-RedfishSystemStorageController
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.SimpleStorage)
    {
        return $ConnectionObject.Systems.SimpleStorage
    }
    else
    {
        throw 'Connection Object does not contain SimpleStorage key under Systems.'    
    }
}
