function Set-RedfishSystemPowerState
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,

        [Parameter(Mandatory = $true)]
        [String]
        [ValidateSet('On','ForceOff','GracefulRestart','GracefulShutdown',IgnoreCase = $false)]
        $PowerState
    )

    #Validate the power state
    $currentPowerState = $ConnectionObject.Systems.PowerState
    if (($currentPowerState -eq 'Off') -and ($powerState -match "ForceOff|GracefulRestart|GracefulShutdown"))
    {
        throw ("{0} is not valid since the current state is {1}" -f $PowerState, $currentPowerState)
    }
    elseif (($currentPowerState -eq 'On') -and ($PowerState -eq 'On'))
    {
        throw 'Current state is same as requested state.'
    }
    
    #Get the session from ConnectionObject
    $header = $ConnectionObject.Token 
    if (!$header.Accept)
    {
        $header.Add('Accept','application/json')
    }
    
    #Build required parameters
    $IPAddress = $header.IPAddress
    $url = "https://${IPAddress}/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset"
    
    #Create the request body
    $requestBody = @{'ResetType' = $PowerState } | ConvertTo-Json -Compress

    $requestParameters = @{
        UseBasicParsing = $true
        Uri = $url
        Body = $requestBody
        ContentType = 'application/json'
        Method = 'Post'
        Headers = $header
    }

    #send the request
    $response = Invoke-WebRequest @requestParameters -Verbose

    if ($response.StatusCode -eq '204')
    {
        Write-Verbose -Message ("Requested powerstate action {0} successful" -f $PowerState)
    }
}
