[cmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [String]
    $ReferenceTag,

    [Parameter(Mandatory = $true)]
    [String[]]
    $DifferenceTag,

    [Parameter(Mandatory = $true)]
    [string[]]
    $ComponentsToCompare
)

foreach ($component in $ComponentsToCompare)
{
    foreach ($system in $DifferenceTag)
    {        
        Describe "Validate $component on $system" {
            $attributeList = (Get-ChildItem -Path "scp:\${ReferenceTag}\SystemConfiguration\${component}").Name
            foreach ($attribute in $attributeList)
            {
                It "Validate ${component}\${attribute} on $system" {
                    (Get-Item -Path "scp:\${system}\SystemConfiguration\${component}\${attribute}").Value | Should Be (Get-Item -Path "scp:\${ReferenceTag}\SystemConfiguration\${component}\${attribute}").Value
                }
            }
        }
    }
}
