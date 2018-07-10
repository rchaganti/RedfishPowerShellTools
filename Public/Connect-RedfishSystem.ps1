function Connect-RedfishSystem
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $IPAddress,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential
    )
    
    #Script block for PowerShell runspaces
    $scriptblock = {
        Param (
            [Parameter(Mandatory = $true)]
            [string]
            $IPAddress,

            [Parameter(Mandatory = $true)]
            [String]
            $Endpoint,

            [Parameter(Mandatory = $true)]
            [pscredential]
            $Credential,

            [Parameter(Mandatory = $true)]
            [string]
            $ResourceName
        )

        Import-Module -Name RedfishPowerShellTools
        $response = Get-RedfishEndpointData -IPAddress $IPAddress -Endpoint $Endpoint -Credential $Credential -ErrorAction SilentlyContinue
        return $resourceName, $response
    }

    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()

    $serviceRoot = "https://${IPAddress}/redfish/v1"

    #Synchronized object for data sharing and endpoint data
    $hash = [hashtable]::new()

    #Runspace plumbing
    $pool = [RunspaceFactory]::CreateRunspacePool(1, [int]$env:NUMBER_OF_PROCESSORS + 1)
    $pool.ApartmentState = "MTA"
    $pool.Open()

    $runspaces = @()

    if ($srObject = Get-RedfishServiceRoot -IPAddress $IPAddress -ErrorAction SilentlyContinue)
    {
        $srObject.psObject.Properties.Remove('@odata.context')
        $srObject.psObject.Properties.Remove('@odata.id')

        foreach ($property in $srObject.PSObject.Properties.Name)
        {        
            #This means we have a property with an oData ID. This could be a collection.
            if (($srObject.$property -is [PSCustomObject]) -and ($srObject.$property.PSObject.Properties.Count -eq 1) -and ($srObject.$Property.'@odata.id'))
            {
                #Create a runspace and add the resulting object to the Synchronized object
                Write-Verbose -Message ("Creating runspace for {0} endpoint" -f $($srObject.$property.'@odata.id'))
                $runspace = [runspacefactory]::CreateRunspace()
                $runspace.Open()
                $runspace.SessionStateProxy.SetVariable('Hash',$hash)

                $powershell = [powershell]::Create()
                $powershell.Runspace = $runspace
            
                $null = $powershell.AddScript($scriptblock)
                $null = $powershell.AddArgument($IPAddress)
                $null = $powershell.AddArgument($srObject.$property.'@odata.id')
                $null = $powershell.AddArgument($Credential)
                $null = $powershell.AddArgument($Property)
                $powershell.RunspacePool = $pool
                $runspaces += [PSCustomObject]@{ Pipe = $powershell; Status = $powershell.BeginInvoke() }
            }
            else
            {
                $hash.Add($property, $srObject.$property)
            }
        }
    }

    #Wait till all the runspaces complete
    Write-Verbose -Message "Waiting till the runspaces exit ..."

    while ($runspaces.Status -ne $null)
    {
        $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }
        foreach ($runspace in $completed)
        {
            $result = $runspace.Pipe.EndInvoke($runspace.Status)
            Write-Verbose -Message ("Completed processing {0} endpoint." -f $result[0])
            $hash.Add($result[0], $result[1])
            $runspace.Status = $null
        }

        Start-Sleep -Seconds 1
    }

    $pool.Close()
    $pool.Dispose()

    Write-Verbose -Message ("Total time (Minutes) to complete Redfish data processing {0}" -f $($stopwatch.Elapsed.TotalMinutes))
    return $hash
}
