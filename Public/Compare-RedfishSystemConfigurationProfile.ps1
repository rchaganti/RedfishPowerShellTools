function Compare-RedfishSystemConfigurationProfile
{
    [CmdletBinding(DefaultParameterSetName = 'ReferenceSystem')]
    param 
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'ReferenceSCP')]
        [String]
        $ReferenceSCP,

        [Parameter(ParameterSetName = 'ReferenceSCP')]        
        [String[]]
        $DifferenceSCP,

        [Parameter(Mandatory = $true, ParameterSetName = 'ReferenceSystem')]
        [Hashtable]
        $ReferenceSystem,

        [Parameter(Mandatory = $true, ParameterSetName = 'ReferenceSystem')]
        [Parameter(ParameterSetName = 'ReferenceSCP')]
        [Hashtable[]]
        $DifferenceSystem,

        [Parameter(ParameterSetName = 'ReferenceSystem')]
        [Parameter(ParameterSetName = 'ReferenceSCP')]
        [String[]]
        $ComponentsToCompare = @('iDRAC.Embedded.1','System.Embedded.1','BIOS.Setup.1-1')
    )

    #Create the drive if it does not exist
    if (-not (Get-PSDrive -Name SCP -ErrorAction SilentlyContinue))
    {
        $null = New-PSDrive -Name SCP -PSProvider SHiPS -Root 'RedfishPowerShellTools#ServerRoot'
    }
    
    if ($ReferenceSCP -and ($DifferenceSCP -and $DifferenceSystem))
    {
        throw "Both DifferenceSCP and DifferenceSystem cannot be provided with Reference SCP."
    }

    #Mount the reference configuration
    if ($ReferenceSCP)
    {
        #Mount the SCP
        $referenceTag = Mount-RedfishSystemConfigurationProfile -ScpJsonFile $ReferenceSCP
    }
    else
    {
        #Mount the reference system SCP
        $referenceTag = Mount-RedfishSystemConfigurationProfile -ConnectionObject $ReferenceSystem -Verbose
    }

    #Mount the difference configuration(s)
    $differenceTags = @()
    if ($DifferenceSCP)
    {
        foreach ($scp in $DifferenceSCP)
        {
            $differenceTags += Mount-RedfishSystemConfigurationProfile -ScpJsonFile $scp -Verbose
        }
    }
    elseif ($DifferenceSystem)
    {
        foreach ($system in $DifferenceSystem)
        {
            $differenceTags += Mount-RedfishSystemConfigurationProfile -ConnectionObject $system
        }
    }

    #Compare using Pester
    $testScriptPath = "${PSScriptRoot}\RedfishSystemConfigurationProfile.Tests.ps1"
    $testResultPath = "${env:Temp}\testresult.xml"

    $testResult = Invoke-Pester -Script @{
        Path = $testScriptPath
        Parameters = @{
            ReferenceTag   = $referenceTag
            DifferenceTag  = $differenceTags
            ComponentsToCompare = $ComponentsToCompare
        }
    } -PassThru -Quiet

        
    if ($testResult.FailedCount -gt 0)
    {
        $failedTests = $testResult.TestResult.Where({$_.Result -eq 'Failed'})

        $failedAttributes = @()

        foreach ($test in $failedTests)
        {
            $testName = $test.Name            
            $tmpArray = $testName.Split(' ')
            $serviceTag = $tmpArray[-1]
            $componentName = $tmpArray[1].Split('\')[0]
            $attributeName = $tmpArray[1].Split('\')[1]

            $failureMessage = $test.FailureMessage.ToString()

            #Get current Value
            $startIndexLast = $failureMessage.LastIndexOf('{')
            $endIndexLast = $failureMessage.LastIndexOf('}')
            $charCount = $endIndexLast - $startIndexLast -1
            $currentValue = $failureMessage.Substring($startIndexLast+1, $charCount)

            #Get expected value
            $startIndex = $failureMessage.indexOf('{')
            $endIndex = $failureMessage.indexOf('}')
            $charCount = $endIndex - $startIndex -1
            $expectedValue = $failureMessage.Substring($startIndex+1, $charCount)

            $failedAttributeObject = New-Object -TypeName PSCustomObject -Property @{
                ServiceTag = $serviceTag
                Component = $componentName
                Attribute = $attributeName
                Expected = $expectedValue
                Current = $currentValue
            }

            $failedAttributeObject.psObject.TypeNames.Insert(0,'Redfish.System.ValidatedAttribute')
            $failedAttributes += $failedAttributeObject
        }

        return $failedAttributes
    }
}
