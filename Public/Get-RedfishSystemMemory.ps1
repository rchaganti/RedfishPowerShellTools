function Get-RedfishSystemMemory
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.Memory)
    {
        return $ConnectionObject.Systems.Memory
    }
    else
    {
        throw 'Connection Object does not contain Memory key under Systems.'    
    }
}
