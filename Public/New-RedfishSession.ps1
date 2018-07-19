function New-RedfishSession
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential
    )

    #Create the username;password hashtable
    $bstrString = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
    $bstrPointer = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstrString)
    
    $credentialHash = @{'UserName'=$Credential.UserName;'Password'=$bstrPointer}
    $requestData = $credentialHash | ConvertTo-Json


    #Invoke request to create a session
    $requestParameters = @{
        Uri = "https://${IPAddress}/redfish/v1/Sessions"
        Method = 'POST'
        Body = $requestData
        ContentType ='application/json'
    }

    try
    {
        $response = Invoke-WebRequest @requestParameters
        if (($response.StatusCode -eq 201) -or ($response.StatusCode -eq 200))
        {
            return @{
                'X-Auth-Token' = $response.Headers['X-Auth-Token']
                'Location' = $response.Headers['Location']
                'IPAddress' = $IPAddress
            }
        }
    }
    catch
    {
        Write-Error $_
    }
}
