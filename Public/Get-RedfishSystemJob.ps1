function Get-RedfishSystemJob
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,

        [Parameter(Mandatory = $true)]
        [String]
        $JobID,

        [Parameter()]
        [Switch]
        $Wait
    )

    #Get the session from ConnectionObject
    $header = $ConnectionObject.Token
    if (!$header.Accept)
    {
        $header.Add('Accept','application/json')
    }
    $IPAddress = $header.IPAddress

    $jobUri = "https://${IPAddress}/redfish/v1/Managers/iDRAC.Embedded.1/Jobs/${JobID}"
    $requestParameters = @{
        Uri = $jobUri
        UseBasicParsing = $true
        Headers = $header
        ContentType = 'application/json'
    }

    $response = Invoke-WebRequest @requestParameters -Verbose -ErrorAction SilentlyContinue
    if ($response.StatusCode -match "200|204")
    {
        $responseObject = $response.Content | ConvertFrom-Json
        if ($Wait)
        {
            Write-Progress -Activity $responseObject.JobType -Status "$($responseObject.JobState) - $($responseObject.PercentComplete)% complete." -PercentComplete $responseObject.PercentComplete
            While (($responseObject.PercentComplete -ne 100) -or ($responseObject.JobState -eq 'Running'))
            {
                $response = Invoke-WebRequest @requestParameters -Verbose -ErrorAction SilentlyContinue
                $responseObject = $response.Content | ConvertFrom-Json
                Write-Progress -Activity $responseObject.JobType -Status "$($responseObject.JobState) - $($responseObject.PercentComplete)% complete." -PercentComplete $responseObject.PercentComplete
                Start-Sleep -Seconds 2
            }

            #return the final job object
            $response = Invoke-WebRequest @requestParameters -Verbose -ErrorAction SilentlyContinue
            Write-Progress -Activity $responseObject.JobType -Status "$($responseObject.JobState) - $($responseObject.PercentComplete)% complete." -Completed
        }
    }
    else
    {
        throw ("Error retrieving job {0} details." -f $JobID)
    }

    return ($response.Content | ConvertFrom-Json)
}
