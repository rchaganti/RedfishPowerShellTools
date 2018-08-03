using namespace Microsoft.PowerShell.SHiPS

[SHiPSProvider()]
class ServerRoot : SHiPSDirectory
{
    static [System.Collections.Generic.List``1[Object]] $availableServers

    #Default contructor
    ServerRoot([string]$name) : base($name)
    {
    }

    [Object[]] GetChildItem()
    {
        $obj = @()

        if ([ServerRoot]::availableServers)
        {
            [ServerRoot]::availableServers | ForEach-Object {
                $obj += [Server]::new($_.SystemConfiguration.ServiceTag, $_)
            }
        }
        return $obj
    }
}

[SHiPSProvider()]
class Server : SHiPSDirectory
{
    hidden [object] $serverCP
    [string] $Model
    [string] $Type  = 'Server'

    #Default contructor
    Server([string]$name, [object]$serverCP) : base($name)
    {
        $this.serverCP = $serverCP
        $this.Model = $serverCP.SystemConfiguration.Model
    }

    [Object[]] GetChildItem()
    {
        $obj = @()
        $obj += [ServerConfiguration]::new('SystemConfiguration', $this.serverCP)
        if ($this.serverCP.FirmwareInventory)
        {
            $obj += [ServerFirmwareInventory]::new('FirmwareInventory', $this.serverCP)
        }
        return $obj
    }
}

[SHiPSProvider()]
class ServerConfiguration : SHiPSDirectory
{
    hidden [object] $serverCP

    #Default Constructor
    ServerConfiguration([string] $name, [object]$serverCP) : base($name)
    {
        $this.serverCP = $serverCP
    }

    [Object[]] GetChildItem()
    {
        $obj = @()
        foreach ($FQDD in $this.serverCP.SystemConfiguration.Components.FQDD)
        {
            $obj += [ServerComponent]::new($FQDD, $this.serverCP)
        }
        return $obj
    }
}

[SHiPSProvider()]
class ServerFirmwareInventory : SHiPSDirectory
{
    hidden [object] $serverCP

    #Default Constructor
    ServerFirmwareInventory([string] $name, [object]$serverCP) : base($name)
    {
        $this.serverCP = $serverCP
    }

    [Object[]] GetChildItem()
    {
        $obj = @()
        foreach ($object in $this.serverCP.FirmwareInventory)
        {
            $obj += [ServerFirmwareInventoryInformation]::new($object.Name, $object)
        }
        return $obj
    }
}

[SHiPSProvider()]
class ServerComponent : SHiPSDirectory
{
    hidden [Object] $serverCP
    [String] $type = 'Component'

    #Default contructor
    ServerComponent([string]$name, [object]$serverCP) : base($name)
    {
        $this.serverCP   = $serverCP
    }

    [Object[]] GetChildItem()
    {
        $obj = @()
        $fqdd = $this.name
        $attributes = $this.ServerCP.SystemConfiguration.Components.Where({$_.FQDD -eq $fqdd}).Attributes
        
        foreach($attribute in $attributes)
        {
            $obj += [ServerComponentAttribute]::new($attribute.Name, $attribute)
        }
        return $obj
    }
}

[SHiPSProvider()]
class ServerComponentAttribute : SHiPSLeaf
{
    hidden [Object] $attributeData
    [string] $Value
    [bool] $SetOnImport
    [string] $comment
    [String] $type = 'Attribute'

    #Default contructor
    ServerComponentAttribute([string]$name, [object]$attributeData) : base($name)
    {
        $this.attributeData   = $attributeData
        $this.Value      = $attributeData.Value
        $this.SetOnImport = $attributeData.'Set On Import'
        $this.Comment = $attributeData.Comment
    }
}

[SHiPSProvider()]
class ServerFirmwareInventoryInformation : SHiPSLeaf
{
    hidden [Object] $InventoryData
    [string] $State
    [bool] $Updateable
    [string] $Health
    [string] $Version
    [String] $InstallState

    #Default contructor
    ServerFirmwareInventoryInformation([string]$name, [object]$InventoryData) : base($name)
    {
        $this.InventoryData   = $InventoryData
        $this.State      = $InventoryData.State
        $this.Updateable = $InventoryData.Updateable
        $this.Health = $InventoryData.Health
        $this.Version = $InventoryData.Version
        $this.InstallState = $inventoryData.InstallState
    }
}    

