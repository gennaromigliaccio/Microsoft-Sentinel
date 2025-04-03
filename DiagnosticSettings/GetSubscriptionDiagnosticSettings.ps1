# Get the list of subscriptions
$subscriptions = Get-AzSubscription

# Loop through each subscription

foreach ($subscription in $subscriptions) {

    # Set the context to the current subscription
    Set-AzContext -SubscriptionId $subscription.Id

    # Get the diagnostic settings for each subscription
    $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId "/subscriptions/$($subscription.Id)"

    # Add the results to the array

    $results += [PSCustomObject]@{
        SubscriptionId = $subscription.Id
        SubscriptionName = $subscription.Name
        DiagnosticSettings = $diagnosticSettings.Name
    }
}

# Export the results array into CSV file
$results | Export-Csv -Path "SubDiagnostics.csv" -NoTypeInformation

