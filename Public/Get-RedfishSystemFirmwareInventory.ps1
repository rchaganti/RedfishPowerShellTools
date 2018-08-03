function Get-RedfishSystemFirmwareInventory
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,

        [Parameter()]
        [Switch]
        $InstalledOnly
    )

    if ($ConnectionObject.UpdateService.FirmwareInventory)
    {
        $firmwareInventory = $ConnectionObject.UpdateService.FirmwareInventory
        #$firmwareInvetory.PSObject.TypeNames.Insert(0,"Redfish.System.FirmwareInventory")

        if ($InstalledOnly)
        {
            return $firmwareInventory.Where({$_.Id -like "*Installed*"})
        }
        else
        {
            return $firmwareInventory
        }
    }
    else
    {
        throw 'ConnectionObject does not have a key by name Firmware Inventory under UpdateService.'
    }
}
