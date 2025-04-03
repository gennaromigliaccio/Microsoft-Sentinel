# Part 2 - Import the .CSV with the subscriptions you want to modify
#Hard coded to look for "SubscriptionToLa" diagnostic settings, please adjust below if needed.
 

# Import the list of SubscriptionIDs from a CSV file
$subscriptionIDs = Import-Csv -Path "SubDiagnostics2.csv"

# Loop through each SubscriptionID and remove the diagnostic settings

foreach ($subscription in $subscriptionIDs) {
    $subscriptionID = $subscription.SubscriptionId

    # Set the context to the current subscription
    Set-AzContext -SubscriptionId $subscriptionID

    # Get all diagnostic settings for the subscription
    $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId "/subscriptions/$subscriptionID"

    # Loop through each diagnostic setting and remove the ones called "subscriptionToLa"

    foreach ($setting in $diagnosticSettings) {
        if ($setting.Name -eq "subscriptionToLa") {
            Remove-AzDiagnosticSetting -ResourceId "/subscriptions/$subscriptionID" -Name $setting.Name
            Write-Host "Removed diagnostic setting 'subscriptionToLa' from subscription $subscriptionID"
        }
    }
}
