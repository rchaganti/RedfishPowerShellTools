function Get-RedfishSystemNetworkDeviceView
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )

    if ($ConnectionObject.Systems.NetworkInterfaces)
    {
        return $ConnectionObject.Systems.NetworkInterfaces
    }
    else
    {
        throw 'Connection Object does not contain NetworkInterfaces key under Systems.'    
    }
}
