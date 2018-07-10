function Get-RedfishSystemProcessor
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.Processors)
    {
        return $ConnectionObject.Systems.Processors
    }
    else
    {
        throw 'Connection Object does not contain Processors key under Systems.'    
    }
}
