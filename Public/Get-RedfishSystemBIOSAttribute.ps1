function Get-RedfishSystemBiosAttribute
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,

        [Parameter()]
        [String]
        $AttributeName
    )

    $biosAttributes = $ConnectionObject.Systems.Bios.Attributes
    if ($biosAttributes)
    {
        if ($AttributeName)
        {
            return $biosAttributes.$AttributeName
        }
        else
        {
            return $biosAttributes    
        }
    }
    else
    {
        throw 'Unable to find BIOS Attributes key.'    
    }
}
