#RetentionInDays = "Hot" Retention
#TotalRetentionInDays = Archive - RetentionInDays

##Step 1: Export ALL table names from LAW into CSV
#Make sure you have storage mounted
#Update RGNAME & LAWNAME

$RG = "Resource Group Name"
$WS = "LAW Workspace Name"

Get-AzOperationalInsightsTable -ResourceGroupName $RG -WorkspaceName $WS | export-csv "SentinelTables.csv"
#Download CSV file, make changes to the "RetentionInDays" column.
#Options: 90, 120, 180, 270, 365, 550, 730
#Upload  file

Import-CSV “SentinelTables2.csv” | foreach {Update-AzOperationalInsightsTable -ResourceGroupName $RG -WorkspaceName $WS -TableName $_.Name -RetentionInDays 180}
