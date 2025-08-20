###### Subscription Foreach 

$diagnosticSettings = @()

$Subscriptions = Get-AzSubscription

Foreach ($Subscription in $Subscriptions) {

Set-Azcontext $subscription

####### Get the NSG Diagnostic Settings

$logicApps = Get-AzResource -ResourceType "Microsoft.Logic/workflows"

foreach ($app in $logicApps) {

$Settings = Get-AzDiagnosticSetting -ResourceId $app.ResourceId

foreach ($setting in $settings) {
        $diagnosticSettings += [PSCustomObject]@{
            LogicAppName = $app.Name
            ResourceGroupName = $app.ResourceGroupName
            DiagnosticSettingName = $setting.Name
		ResourceId = $app.id
		       				}


				}

					}
}


####### Export the diagnostic settings to a CSV file


$diagnosticSettings | Export-Csv -Path "LogicAppDiagnosticSettings.csv" -NoTypeInformation


####### Removal of Diagnostic Settings via CSV


$diagnosticSettings = Import-Csv -Path "LogicAppDiagnosticSettingsUPDATED.csv"


foreach ($setting in $diagnosticSettings) {
$resourceid = $setting.resourceid
    Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $setting.DiagnosticSettingName

}
