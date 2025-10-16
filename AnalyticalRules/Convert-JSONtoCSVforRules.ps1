function Convert-SentinelAlertJsonToCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, HelpMessage="Path to ARM template JSON or a folder")]
        [string]$Path,

        [Parameter(HelpMessage="Output CSV path (defaults to <input>.csv or <folder>\SentinelAlertRules.csv)")]
        [string]$OutFile
    )

    function Get-Prop($o, $name) {
        if ($null -eq $o) { return $null }
        $p = $o.PSObject.Properties[$name]
        if ($p) { return $p.Value } else { return $null }
    }

    $files = @()
    if (Test-Path $Path -PathType Leaf) {
        $files = ,(Resolve-Path $Path).Path
        if (-not $OutFile) { $OutFile = [IO.Path]::ChangeExtension($files[0], '.csv') }
    } elseif (Test-Path $Path -PathType Container) {
        $files = Get-ChildItem -Path $Path -Filter *.json -File -Recurse | ForEach-Object FullName
        if (-not $OutFile) { $OutFile = Join-Path $Path 'SentinelAlertRules.csv' }
    } else {
        throw "Path not found: $Path"
    }

    $rows = New-Object System.Collections.Generic.List[object]

    foreach ($file in $files) {
        try {
            $raw = Get-Content -Path $file -Raw -ErrorAction Stop
            $json = $raw | ConvertFrom-Json -ErrorAction Stop

            # If it's a single rule object (not an ARM template), normalize to an array
            if ($json.resources) {
                $resources = $json.resources
            } elseif ($json.kind -or $json.type -or $json.properties) {
                $resources = ,$json
            } elseif ($json -is [System.Array]) {
                $resources = $json
            } else {
                Write-Warning "No resources found in $file"
                continue
            }

            foreach ($r in $resources) {
                # Only alert rules
                $type = (Get-Prop $r 'type')
                if (-not $type -or ($type -notmatch '/alertRules$')) {
                    # Some exports omit 'type' at this level – check 'kind' or properties as fallback
                    if (-not (Get-Prop $r 'properties')) { continue }
                }

                $props = Get-Prop $r 'properties'
                if (-not $props) { continue }

                # Basic fields
                $id          = Get-Prop $r 'id'
                $name        = Get-Prop $r 'name'
                $kind        = Get-Prop $r 'kind'
                $apiVersion  = Get-Prop $r 'apiVersion'
                $displayName = Get-Prop $props 'displayName'
                $description = Get-Prop $props 'description'
                $severity    = Get-Prop $props 'severity'
                $enabled     = Get-Prop $props 'enabled'
                $query       = Get-Prop $props 'query'
                # Keep line breaks but normalize CRLF -> LF for CSV consistency
                if ($query) { $query = $query -replace "`r`n","`n" }

                $queryFrequency    = Get-Prop $props 'queryFrequency'
                $queryPeriod       = Get-Prop $props 'queryPeriod'
                $triggerOperator   = Get-Prop $props 'triggerOperator'
                $triggerThreshold  = Get-Prop $props 'triggerThreshold'
                $suppressionDur    = Get-Prop $props 'suppressionDuration'
                $suppressionEn     = Get-Prop $props 'suppressionEnabled'
                $tactics           = (Get-Prop $props 'tactics') -join ';'
                $techniques        = (Get-Prop $props 'techniques') -join ';'
                $subTechniques     = (Get-Prop $props 'subTechniques') -join ';'

                # Incident / grouping
                $incCfg            = Get-Prop $props 'incidentConfiguration'
                $createIncident    = if ($incCfg) { Get-Prop $incCfg 'createIncident' } else { $null }
                $grouping          = if ($incCfg) { Get-Prop $incCfg 'groupingConfiguration' } else { $null }
                $groupingEnabled   = if ($grouping) { Get-Prop $grouping 'enabled' } else { $null }
                $reopenClosed      = if ($grouping) { Get-Prop $grouping 'reopenClosedIncident' } else { $null }
                $lookbackDur       = if ($grouping) { Get-Prop $grouping 'lookbackDuration' } else { $null }
                $matchingMethod    = if ($grouping) { Get-Prop $grouping 'matchingMethod' } else { $null }
                $groupByEntities   = if ($grouping) { (Get-Prop $grouping 'groupByEntities') -join ';' } else { $null }
                $groupByAlertDet   = if ($grouping) { (Get-Prop $grouping 'groupByAlertDetails') -join ';' } else { $null }
                $groupByCustomDet  = if ($grouping) { (Get-Prop $grouping 'groupByCustomDetails') -join ';' } else { $null }

                # Event Grouping
                $egs               = Get-Prop $props 'eventGroupingSettings'
                $aggregationKind   = if ($egs) { Get-Prop $egs 'aggregationKind' } else { $null }

                # Alert details override
                $ado               = Get-Prop $props 'alertDetailsOverride'
                $alertNameFormat   = if ($ado) { Get-Prop $ado 'alertDisplayNameFormat' } else { $null }

                # Entity mappings (flatten nicely)
                $entityMappings    = Get-Prop $props 'entityMappings'
                $entityMapStr = $null
                if ($entityMappings) {
                    $pairs = foreach ($em in $entityMappings) {
                        $etype = Get-Prop $em 'entityType'
                        $fms = Get-Prop $em 'fieldMappings'
                        if ($fms) {
                            foreach ($fm in $fms) {
                                $idn = Get-Prop $fm 'identifier'
                                $col = Get-Prop $fm 'columnName'
                                "{0}:{1}={2}" -f $etype,$idn,$col
                            }
                        }
                    }
                    $entityMapStr = ($pairs | Where-Object { $_ }) -join ';'
                }

                # Custom details (as key=value;key2=value2)
                $customDetails = Get-Prop $props 'customDetails'
                $customDetailsStr = $null
                if ($customDetails -and $customDetails -isnot [string]) {
                    $kv = foreach ($p in $customDetails.PSObject.Properties) {
                        "{0}={1}" -f $p.Name, $p.Value
                    }
                    $customDetailsStr = ($kv) -join ';'
                }

                # Try to pull a rule Guid from id/name if present
                $ruleGuid = $null
                foreach ($source in @($name, $id)) {
                    if ($source -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
                        $ruleGuid = $matches[1]; break
                    }
                }

                $rows.Add([pscustomobject]@{
                    SourceFile               = $file
                    RuleGuid                 = $ruleGuid
                    Id                       = $id
                    Name                     = $name
                    Kind                     = $kind
                    ApiVersion               = $apiVersion
                    DisplayName              = $displayName
                    Description              = $description
                    Severity                 = $severity
                    Enabled                  = $enabled
                    Query                    = $query
                    QueryFrequency           = $queryFrequency
                    QueryPeriod              = $queryPeriod
                    TriggerOperator          = $triggerOperator
                    TriggerThreshold         = $triggerThreshold
                    SuppressionDuration      = $suppressionDur
                    SuppressionEnabled       = $suppressionEn
                    Tactics                  = $tactics
                    Techniques               = $techniques
                    SubTechniques            = $subTechniques
                    CreateIncident           = $createIncident
                    GroupingEnabled          = $groupingEnabled
                    ReopenClosedIncident     = $reopenClosed
                    GroupingLookbackDuration = $lookbackDur
                    GroupingMatchingMethod   = $matchingMethod
                    GroupByEntities          = $groupByEntities
                    GroupByAlertDetails      = $groupByAlertDet
                    GroupByCustomDetails     = $groupByCustomDet
                    AggregationKind          = $aggregationKind
                    AlertDisplayNameFormat   = $alertNameFormat
                    EntityMappings           = $entityMapStr
                    CustomDetails            = $customDetailsStr
                })
            }
        } catch {
            Write-Warning "Failed to process ${file}: $($_.Exception.Message)"
        }
    }

    if ($rows.Count -eq 0) {
        Write-Warning "No alert rules found."
        return
    }

    $rows | Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8
    Write-Host "✅ Exported $($rows.Count) alert rule(s) to: $OutFile"
}

# EXAMPLE USAGE:
# Convert a single ARM template file
# Convert-SentinelAlertJsonToCsv -Path 'C:\Temp\sentinel-alerts.json' -OutFile 'C:\Temp\sentinel-alerts.csv'
#
# Or process all JSONs under a folder recursively
# Convert-SentinelAlertJsonToCsv -Path 'C:\Temp\SentinelExports' 
