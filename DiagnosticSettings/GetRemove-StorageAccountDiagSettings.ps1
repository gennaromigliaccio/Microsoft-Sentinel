####### Subscription foreach


$DiagResults = @()

$Subscriptions = Get-AzSubscription

Foreach ($Subscription in $Subscriptions) {

Set-Azcontext $subscription

$StorageAccounts = Get-AzStorageAccount



###### Storage Account Diagnostic Settings

Foreach ($StorageAccount in $StorageAccounts) {

$ResourceGroup = $StorageAccount.ResourceGroupName
$SAN = $StorageAccount.StorageAccountName

$diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $storageaccount.id

# PS Object for Results
            $item = [PSCustomObject]@{
                StorageAccountName = $SAN
		SettingType = "Account"
                DiagnosticSettingsName = $diagnosticsettings.name
                Subscription = $Subscription
		SubscriptionName = $Subscription.name
                ResourceId = $storageaccount.id
            }
            Write-Host $item
            # Add PS Object to array
            $DiagResults += $item

	}


####### BLOB Diagnostic Settings

Foreach ($StorageAccount in $StorageAccounts) {

$ResourceGroup = $StorageAccount.ResourceGroupName
$SAN = $StorageAccount.StorageAccountName
$ResourceId = "/subscriptions/$subscription/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$SAN/blobServices/default"
$diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $resourceId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

# PS Object for Results
            $item = [PSCustomObject]@{
                StorageAccountName = $SAN
		SettingType = "Blob"
                DiagnosticSettingsName = $diagnosticsettings.name
                Subscription = $Subscription
		SubscriptionName = $Subscription.name
                ResourceId = $resourceId
            }
            Write-Host $item
            # Add PS Object to array
            $DiagResults += $item

	}


############## QUEUE Diagnostic Settings

Foreach ($StorageAccount in $StorageAccounts) {

$ResourceGroup = $StorageAccount.ResourceGroupName
$SAN = $StorageAccount.StorageAccountName
$ResourceId = "/subscriptions/$subscription/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$SAN/queueServices/default"
$diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $resourceId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

# PS Object for Results
            $item = [PSCustomObject]@{
                StorageAccountName = $SAN
		SettingType = "Queue"
                DiagnosticSettingsName = $diagnosticsettings.name
                Subscription = $Subscription
		SubscriptionName = $Subscription.name
                ResourceId = $resourceId
            }
            Write-Host $item
            # Add PS Object to array
            $DiagResults += $item

	}

################### TABLE Diagnostic Settings

Foreach ($StorageAccount in $StorageAccounts) {

$ResourceGroup = $StorageAccount.ResourceGroupName
$SAN = $StorageAccount.StorageAccountName
$ResourceId = "/subscriptions/$subscription/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$SAN/tableServices/default"
$diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $resourceId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

# PS Object for Results
            $item = [PSCustomObject]@{
                StorageAccountName = $SAN
		SettingType = "Table"
                DiagnosticSettingsName = $diagnosticsettings.name
                Subscription = $Subscription
		SubscriptionName = $Subscription.name
                ResourceId = $resourceId
            }
            Write-Host $item
            # Add PS Object to array
            $DiagResults += $item

	}

############### FILE Diagnostic Settings

Foreach ($StorageAccount in $StorageAccounts) {

$ResourceGroup = $StorageAccount.ResourceGroupName
$SAN = $StorageAccount.StorageAccountName
$ResourceId = "/subscriptions/$subscription/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$SAN/fileServices/default"
$diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $resourceId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

# PS Object for Results
            $item = [PSCustomObject]@{
                StorageAccountName = $SAN
		SettingType = "File"
                DiagnosticSettingsName = $diagnosticsettings.name
                Subscription = $Subscription
		SubscriptionName = $Subscription.name
                ResourceId = $resourceId
            }
            Write-Host $item
            # Add PS Object to array
            $DiagResults += $item

	}

}

#####Export

$DiagResults | Export-Csv -Force -Path "AzureStorageAccountDiagnosticSettings5.csv"

#You will need to filter out the ones that do not have a diagnostic setting

###############################################
###############################################
###############################################
######           Removal of diagnostic settings

$CSVremove = Import-Csv -Path "AzureStorageAccountDiagnosticSettingsUPDATE5.csv"


foreach ($row in $CSVremove) {
    Remove-AzDiagnosticSetting -ResourceId $row.ResourceId -Name $row.DiagnosticSettingsName

write-host "Removed $row.DiagnosticSettingName"
}
