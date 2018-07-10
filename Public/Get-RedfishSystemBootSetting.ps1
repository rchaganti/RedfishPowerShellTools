function Get-RedfishSystemBootSetting
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.Boot)
    {
        return $ConnectionObject.Systems.Boot
    }
    else
    {
        throw 'Connection Object does not contain Boot key under Systems.'    
    }
}
