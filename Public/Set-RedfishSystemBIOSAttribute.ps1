function Set-RedfishSystemBIOSAttribute
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,

        [Parameter(Mandatory = $true)]
        [String]
        $AttributeName,

        [Parameter(Mandatory = $true)]
        [String]
        $AttributeValue
    )

    #Get the session from ConnectionObject
    $header = $ConnectionObject.Token
    if (!$header.Accept)
    {
        $header.Add('Accept','application/json')
    }

    $IPAddress = $header.IPAddress

    #Validate that the attribute exists and it's value is not same as what is requested.
    if ($currentValue = Get-RedfishSystemBiosAttribute -ConnectionObject $ConnectionObject -AttributeName $AttributeName)
    {
        if ($AttributeValue -eq $currentValue)
        {
            throw ("Requested attribute value {0} is same as current value." -f $AttributeValue)
        }
    }

    #Validate if the provided AttributeValue is valid for the AttributeName
    $attrRegistry = Get-RedfishSystemBiosAttributeRegistry -ConnectionObject $ConnectionObject
    $attributeMetaData = $attrRegistry.Where({$_.AttributeName -eq $AttributeName})

    if ($attributeMetaData.ReadOnly)
    {
        throw ("{0} is a readonly attribute." -f $AttributeName)
    }
    else
    {
        if (($attributeMetaData.Value.ValueName) -and ($attributeMetaData.Value.ValueName -notcontains $AttributeValue))
        {
            throw ("{0} is not a valid value for {1}. Valid values are {2}" -f $AttributeValue, $AttributeName, $($attributeMetaData.Value.ValueName -join ','))
        }
    }

    #If we reach till here, it is a GO for set.
    $requestBody = @{Attributes=@{$AttributeName=$AttributeValue}} | ConvertTo-Json -Compress

    $requestParameters = @{
        Uri = "https://${IPAddress}/redfish/v1/Systems/System.Embedded.1/Bios/Settings"
        UseBasicParsing = $true
        Headers = $header
        ContentType = 'application/json'
        Method = 'Patch'
        Body = $requestBody
    }

    Write-Verbose -Message 'Setting attribute value ...'
    $response = Invoke-WebRequest @requestParameters -Verbose -ErrorAction SilentlyContinue

    if ($response)
    {
        if ($response.StatusCode -match "200|204")
        {
            #Create a configuration job to complete the configuration change
            $requestParameters.Uri = "https://${IPAddress}/redfish/v1/Managers/iDRAC.Embedded.1/Jobs"
            $requestParameters.Body = @{'TargetSettingsURI' ='/redfish/v1/Systems/System.Embedded.1/Bios/Settings'} | ConvertTo-Json -Compress
            $requestParameters.Method = 'Post'

            $jobResponse = Invoke-WebRequest @requestParameters -Verbose -ErrorAction SilentlyContinue
            if ($jobResponse)
            {
                if ($jobResponse.StatusCode -match "200|204")
                {
                    $jobEndpoint = $jobResponse.Headers.Location

                    #Retrieve the JOB ID
                    $jobId = Split-Path -Path $jobEndpoint -Leaf

                    #Get job details
                    $job = Get-RedfishSystemJob -ConnectionObject $ConnectionObject -JobID $jobId

                    if ($job.JobState -match 'Scheduled|New')
                    {
                        #Set the system to desired state
                        if ($ConnectionObject.Systems.PowerState -eq 'On')
                        {
                            Set-RedfishSystemPowerState -ConnectionObject $ConnectionObject -PowerState 'GracefulRestart'
                        }
                        else
                        {
                            Set-RedfishSystemPowerState -ConnectionObject $ConnectionObject -PowerState On
                        }
                    }
                    else
                    {
                        throw "Job failed to start."
                    }

                    #Wait for job to complete
                    Get-RedfishSystemJob -ConnectionObject $ConnectionObject -JobID $jobId -Wait
                }
            }
        }
    }
}
