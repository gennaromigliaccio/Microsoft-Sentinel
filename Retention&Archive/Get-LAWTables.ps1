$RG = "Resource Group Name"
$WS = "LAW Workspace Name"

Get-AzOperationalInsightsTable -ResourceGroupName $RG -WorkspaceName $WS | export-csv "LAWTables.csv"
