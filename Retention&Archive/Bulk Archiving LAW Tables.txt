##Step 1: Export ALL table names from LAW into CSV
#Make sure you have storage mounted
#Update RGNAME & LAWNAME

$RG = "Resource Group Name"
$WS = "LAW Workspace Name"

Get-AzOperationalInsightsTable -ResourceGroupName $RG -WorkspaceName $WS | export-csv "SentinelTables.csv"

#Step 2: Download CSV
#Check and clean up table
#Upload new CSV file to Cloud Shell
#Note: this is TOTAL RETENTION...So archive days + hot retention = Total Retention

##Step 2: Bulk update tables via CSV

Import-CSV “SentinelTables2.csv” | foreach {Update-AzOperationalInsightsTable -ResourceGroupName $RG -WorkspaceName $WS -TableName $_.Name -TotalRetentionInDays 365}
