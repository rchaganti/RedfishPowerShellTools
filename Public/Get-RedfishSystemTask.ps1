function Get-RedfishSystemTask
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $ConnectionObject,

        [Parameter(Mandatory = $true)]
        [String]
        $TaskID,

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

    $jobUri = "https://${IPAddress}/redfish/v1/TaskService/Tasks/${TaskID}"
    $requestParameters = @{
        Uri = $jobUri
        UseBasicParsing = $true
        Headers = $header
        ContentType = 'application/json'
    }

    $response = Invoke-WebRequest @requestParameters -Verbose -ErrorAction SilentlyContinue
    if ($response.StatusCode -match "200|202|204")
    {
        $responseObject = $response.Content | ConvertFrom-Json
        if ($Wait)
        {
            #Get the job ID and wait for the job to complete
            $jobID = $responseObject.Oem.Dell.Id
            $exportContent = Get-RedfishSystemJob -ConnectionObject $ConnectionObject -JobID $jobID -Wait
        }

        #Get Task status again
        $task = Invoke-WebRequest @requestParameters -Verbose -ErrorAction SilentlyContinue
        return $task
    }
    else
    {
        throw ("Error retrieving job {0} details." -f $TaskID)
    }
}

