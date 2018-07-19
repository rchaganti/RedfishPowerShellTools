function Get-RedfishResourceAction
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject
    )
    
    $actionHash = @{}
    foreach ($key in $ConnectionObject.Keys)
    {    
        $actions = $ConnectionObject.$key.Actions
        if ($actions -ne $null)
        {
            $actionHash.Add($key, @{})
            foreach ($action in $actions.PSObject.Properties.Name)
            {
                if ($action -ne 'Oem')
                {
                    $actionHash.$key.Add($action, @{'Name'='';'Target'=@{};'Properties'=@()})

                    $actionHash.$key.$action.Name = $action.Split('.')[-1]
                    foreach ($property in $actions.$action.PSObject.Properties.Name)
                    {
                        #Anything other than target (property name) is a method parameter 
                        #if the property contains AllowableValues, it is an enum. We can use the allowed values for validate set
                        if ($property -eq 'target')
                        {
                            $actionHash.$key.$action.Target = $actions.$action.$property
                        }
                        elseif ($property -like "*@Redfish.AllowableValues*")
                        {
                            $propertyName = $property.Split('@')[0]
                            $allowedValues = @($actions.$action.$property)
                        }
                        else
                        {
                            $propertyName = $property
                            $allowedValues = $null
                        }

                        $actionHash.$key.$action.Properties += @{
                            Name = $propertyName
                            AllowedValues = $allowedValues
                        }
                    }
                }
                else
                {
                    $oemActions = $actions.oem
                    foreach ($oemAction in $oemActions.PSObject.Properties.Name)
                    {
                        if ($oemAction)
                        {
                            $actionHash.$key.Add($oemAction, @{'Name'='';'Target'=@{};'Properties'=@()})

                            $actionHash.$key.$oemAction.Name = $oemAction.Split('.')[-1]
                            foreach ($property in $oemActions.$oemAction.PSObject.Properties.Name)
                            {
                                #Anything other than target (property name) is a method parameter 
                                #if the property contains AllowableValues, it is an enum. We can use the allowed values for validate set
                                if ($property -eq 'target')
                                {
                                    $actionHash.$key.$oemAction.Target = $oemActions.$oemAction.$property
                                }
                                elseif ($property -like "*@Redfish.AllowableValues*")
                                {
                                    $propertyName = $property.Split('@')[0]
                                    $allowedValues = @($oemActions.$oemAction.$property)                    
                                }
                                else
                                {
                                    $propertyName = $property
                                    $allowedValues = $null
                                }
    
                                if ($actionHash.$key.$oemAction.Properties.Name -notcontains $propertyName)
                                {
                                    $actionHash.$key.$oemAction.Properties += @{
                                        Name = $propertyName
                                        AllowedValues = $allowedValues
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return $actionHash    
}