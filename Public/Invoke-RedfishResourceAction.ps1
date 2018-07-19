function Invoke-RedfishResourceAction
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,

        [Parameter(Mandatory = $true)]
        [String]
        $Resource,    

        [Parameter(Mandatory = $true)]
        [String]
        $Action, 

        [Parameter(Mandatory = $true)]
        [Hashtable]
        $Parameters,         

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential
    )

    #Check if the action exists for the resource
    if ($ConnectionObject.$Resource)
    {
        #get all actions for this resource
        $resourceActions = Get-RedfishResourceAction -ConnectionObject $ConnectionObject
        $actionNames = $resourceActions.$Resource.Values.Name

        if ($actionNames -contains $Action)
        {
            
        }
        else
        {
            throw ("{0} does not contain an action named {1}. The valid values are {2}." -f $Resource, $Action, ($actionNames -join ','))
        }
    }
}
