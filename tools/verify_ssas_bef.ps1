param([string]$ServerName = 'localhost\SSASMD')
$ErrorActionPreference = 'Stop'
$befConnection = New-Object -ComObject ADODB.Connection
try {
    $befConnection.ConnectionTimeout = 10
    $befConnection.CommandTimeout = 60
    $befConnection.Open('Provider=MSOLAP;Data Source=' + $ServerName + ';Initial Catalog=SSAS;Integrated Security=SSPI;')
    $befQueries = [ordered]@{
        b = @'
SELECT {[Measures].[FACT ACCIDENT Count]} ON COLUMNS,
TOPCOUNT(
    NONEMPTY([DIM LOCATION].[CITY].[CITY].MEMBERS,
             [Measures].[FACT ACCIDENT Count]),
    5, [Measures].[FACT ACCIDENT Count])
DIMENSION PROPERTIES MEMBER_CAPTION, KEY0, KEY1 ON ROWS
FROM [US Accidents DW]
WHERE ([ID START DATE].[YEAR].&[2021],
       [ID START DATE].[QUARTER].&[2021]&[2],
       [DIM SEVERITY].[ID SEVERITY].&[4])
'@
        quarters_2021_severity4 = @'
SELECT {[Measures].[FACT ACCIDENT Count]} ON COLUMNS,
NON EMPTY [ID START DATE].[QUARTER].[QUARTER].MEMBERS
DIMENSION PROPERTIES MEMBER_CAPTION, KEY0, KEY1 ON ROWS
FROM [US Accidents DW]
WHERE ([ID START DATE].[YEAR].&[2021], [DIM SEVERITY].[ID SEVERITY].&[4])
'@
        day_night_2021 = @'
SELECT {[Measures].[FACT ACCIDENT Count]} ON COLUMNS,
NON EMPTY ([ID START DATE].[IS WEEKEND].[IS WEEKEND].MEMBERS *
           {[FACT ACCIDENT].[SUNRISE SUNSET].&[Day],
            [FACT ACCIDENT].[SUNRISE SUNSET].&[Night]}) ON ROWS
FROM [US Accidents DW]
WHERE ([ID START DATE].[YEAR].&[2021])
'@
        traffic_signal_members = @'
SELECT {[Measures].[FACT ACCIDENT Count]} ON COLUMNS,
[DIM TRAFFIC SIGNAL].[TRAFFIC SIGNAL].[TRAFFIC SIGNAL].MEMBERS
DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME ON ROWS
FROM [US Accidents DW]
'@
        f_top_state = @'
WITH MEMBER [Measures].[Severity34] AS
SUM({[DIM SEVERITY].[ID SEVERITY].&[3], [DIM SEVERITY].[ID SEVERITY].&[4]},
    [Measures].[FACT ACCIDENT Count])
SELECT {[Measures].[FACT ACCIDENT Count], [Measures].[Severity34]} ON COLUMNS,
TOPCOUNT([DIM LOCATION].[STATE].[STATE].MEMBERS, 1,
         [Measures].[FACT ACCIDENT Count]) ON ROWS
FROM [US Accidents DW]
WHERE ([DIM TRAFFIC SIGNAL].[TRAFFIC SIGNAL].&[True],
       [FACT ACCIDENT].[SUNRISE SUNSET].&[Night])
'@
        hour_members = @'
SELECT {[Measures].[FACT ACCIDENT Count]} ON COLUMNS,
NON EMPTY [ID START TIME].[HOUR].[HOUR].MEMBERS ON ROWS
FROM [US Accidents DW]
'@
    }
    $befSummary = [ordered]@{}
    foreach ($befName in $befQueries.Keys) {
        Write-Output "Verifying $befName..."
        $befRecordset = $befConnection.Execute($befQueries[$befName])
        $befRows = @()
        while (-not $befRecordset.EOF) {
            $befRow = [ordered]@{}
            for ($befIndex = 0; $befIndex -lt $befRecordset.Fields.Count; $befIndex++) {
                $befField = $befRecordset.Fields.Item($befIndex)
                $befRow[$befField.Name] = $befField.Value
            }
            $befRows += [pscustomobject]$befRow
            $befRecordset.MoveNext()
        }
        $befRecordset.Close()
        $befSummary[$befName] = $befRows
        $befRows | ConvertTo-Json -Depth 5
    }
    $befOutput = Join-Path (Split-Path $PSScriptRoot -Parent) 'SSAS\backups\bef_verification.json'
    $befSummary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $befOutput -Encoding UTF8
    Write-Output "Saved verification: $befOutput"
} finally {
    if ($befConnection.State -ne 0) { $befConnection.Close() }
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($befConnection)
}
