

$component_csv = (Split-Path $MyInvocation.MyCommand.Definition) + "\ComponentIDs.csv"
$component_csv 

$ComponentLookup = (Import-Csv -Path  $component_csv)
($ComponentLookup | Where-Object -Property "Enumeration Value" -like "{51DC0B24-7421-45C3-B4AB-9481A683D91D}").Description



