###### Subscription Foreach 

$diagnosticSettings = @()

$Subscriptions = Get-AzSubscription

Foreach ($Subscription in $Subscriptions) {

Set-Azcontext $subscription

####### Get the NSG Diagnostic Settings

$nsgs = Get-AzNetworkSecurityGroup

foreach ($nsg in $nsgs) {
    $settings = Get-AzDiagnosticSetting -ResourceId $nsg.Id
    foreach ($setting in $settings) {
        $diagnosticSettings += [PSCustomObject]@{
            NSGName = $nsg.Name
            ResourceGroupName = $nsg.ResourceGroupName
            DiagnosticSettingName = $setting.Name
		ResourceId = $nsg.id
		        }
    		}
	}
}

####### Export the diagnostic settings to a CSV file


$diagnosticSettings | Export-Csv -Path "NSGDiagnosticSettings.csv" -NoTypeInformation


####### Removal of Diagnostic Settings via CSV


$diagnosticSettings = Import-Csv -Path "NSGDiagnosticSettingsUPDATED.csv"


foreach ($setting in $diagnosticSettings) {
$resourceid = $setting.resourceid
    Remove-AzDiagnosticSetting -ResourceId $resourceId -Name $setting.DiagnosticSettingName

}
