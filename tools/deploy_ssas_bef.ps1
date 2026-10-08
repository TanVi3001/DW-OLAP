param([string]$ServerName = 'localhost\SSASMD', [string]$DatabaseId = 'SSAS')
$ErrorActionPreference = 'Stop'
Add-Type -Path 'C:\Program Files\Microsoft SQL Server\170\DTS\Binn\Microsoft.AnalysisServices.Core.dll'
Add-Type -Path 'C:\Program Files\Microsoft SQL Server\170\DTS\Binn\Microsoft.AnalysisServices.dll'
$befProject = Join-Path (Split-Path $PSScriptRoot -Parent) 'SSAS\SSAS'
$befNamespace = 'http://schemas.microsoft.com/analysisservices/2003/engine'
$befBatch = New-Object System.Xml.XmlDocument
$befBatch.LoadXml('<Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine" Transaction="true" />')
foreach ($befFile in @('DIM TIME.dim', 'DIM LOCATION.dim', 'FACT ACCIDENT.dim', 'US Accidents DW.cube')) {
    $befDefinition = New-Object System.Xml.XmlDocument
    $befDefinition.Load((Join-Path $befProject $befFile))
    foreach ($befNode in @($befDefinition.SelectNodes('//*'))) {
        if ($befNode.NamespaceURI -ne $befNamespace -and $befNode.NamespaceURI -like '*analysisservices*') {
            [void]$befNode.ParentNode.RemoveChild($befNode)
            continue
        }
        if ($befNode.NamespaceURI -eq $befNamespace -and $befNode.LocalName -in @('CreatedTimestamp','LastSchemaUpdate','LastProcessed','State','CurrentStorageMode')) {
            [void]$befNode.ParentNode.RemoveChild($befNode)
            continue
        }
        foreach ($befAttribute in @($befNode.Attributes)) {
            if ($befAttribute.NamespaceURI -eq 'http://schemas.microsoft.com/DataWarehouse/Designer/1.0') {
                [void]$befNode.Attributes.Remove($befAttribute)
            }
        }
    }
    $befIdNode = $befDefinition.DocumentElement.ChildNodes | Where-Object { $_.LocalName -eq 'ID' } | Select-Object -First 1
    $befObjectType = if ($befFile.EndsWith('.dim')) { 'DimensionID' } else { 'CubeID' }
    $befAlter = $befBatch.CreateElement('Alter', $befNamespace)
    $befAlter.SetAttribute('AllowCreate', 'false')
    $befAlter.SetAttribute('ObjectExpansion', 'ExpandFull')
    $befObject = $befBatch.CreateElement('Object', $befNamespace)
    $befDatabaseNode = $befBatch.CreateElement('DatabaseID', $befNamespace)
    $befDatabaseNode.InnerText = $DatabaseId
    [void]$befObject.AppendChild($befDatabaseNode)
    $befId = $befBatch.CreateElement($befObjectType, $befNamespace)
    $befId.InnerText = $befIdNode.InnerText
    [void]$befObject.AppendChild($befId)
    [void]$befAlter.AppendChild($befObject)
    $befObjectDefinition = $befBatch.CreateElement('ObjectDefinition', $befNamespace)
    [void]$befObjectDefinition.AppendChild($befBatch.ImportNode($befDefinition.DocumentElement, $true))
    [void]$befAlter.AppendChild($befObjectDefinition)
    [void]$befBatch.DocumentElement.AppendChild($befAlter)
}
$befProcess = $befBatch.CreateElement('Process', $befNamespace)
$befProcess.InnerXml = '<Object xmlns="' + $befNamespace + '"><DatabaseID>' + $DatabaseId + '</DatabaseID></Object><Type xmlns="' + $befNamespace + '">ProcessFull</Type><WriteBackTableCreation xmlns="' + $befNamespace + '">UseExisting</WriteBackTableCreation>'
[void]$befBatch.DocumentElement.AppendChild($befProcess)
$befPayload = Join-Path (Split-Path $PSScriptRoot -Parent) 'SSAS\backups\bef_deploy.xmla'
$befBatch.Save($befPayload)
$befServer = New-Object Microsoft.AnalysisServices.Server
try {
    $befServer.Connect('Data Source=' + $ServerName + ';Connect Timeout=10')
    Write-Output "Applying and processing SSAS database $DatabaseId on $ServerName..."
    $befResults = $befServer.Execute($befBatch.OuterXml)
    $befFailed = $false
    foreach ($befResult in $befResults) {
        foreach ($befMessage in $befResult.Messages) {
            Write-Output ($befMessage.GetType().Name + ': ' + $befMessage.Description)
            if ($befMessage -is [Microsoft.AnalysisServices.XmlaError]) { $befFailed = $true }
        }
    }
    if ($befFailed) { throw 'XMLA returned errors. The transaction was not committed.' }
    $befServer.Refresh()
    $befDatabase = $befServer.Databases.Find($DatabaseId)
    $befDatabase.Refresh()
    $befDatabase.Dimensions | Select-Object ID, State
    $befDatabase.Cubes | Select-Object ID, State
    Write-Output 'Deployment and Process Full completed.'
} finally {
    if ($befServer.Connected) { $befServer.Disconnect() }
}
