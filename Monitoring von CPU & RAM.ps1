# Funktion, um eine Fehlermeldung auszugeben und in eine Logdatei zu schreiben
function Show-Error {
    param (
        [string]$Message = "Die CPU-Auslastung ist zu hoch!"
    )

    # Fehlermeldung ausgeben
    Write-Host "FEHLER: $Message" -ForegroundColor Red
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($Message, "Warnung", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)

    # Logdatei schreiben
    $logFilePath = "C:\Logs\Warnungen.log"
    if (-not (Test-Path (Split-Path $logFilePath))) {
        New-Item -ItemType Directory -Path (Split-Path $logFilePath) -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Add-Content -Path $logFilePath -Value $logMessage
}

# CPU- und RAM-Auslastung überwachen
while ($true) {
    # CPU-Auslastung abrufen (Alternativmethode mit WMI für bessere Kompatibilität)
    $cpuUsage = Get-WmiObject -Query "SELECT LoadPercentage FROM Win32_Processor" | Select-Object -ExpandProperty LoadPercentage

    # RAM-Auslastung abrufen
    $totalMemory = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory
    $freeMemory = (Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory * 1024
    $usedMemory = $totalMemory - $freeMemory
    $ramUsagePercentage = [math]::Round(($usedMemory / $totalMemory) * 100, 2)

    # Wenn die CPU-Auslastung über 80% liegt
    if ($cpuUsage -gt 80) {
        Show-Error -Message "Die CPU-Auslastung liegt bei $cpuUsage% und ist über dem Grenzwert!"
    } 

    # Wenn die RAM-Auslastung über 80% liegt
    if ($ramUsagePercentage -gt 30) {
        Show-Error -Message "Die RAM-Auslastung liegt bei $ramUsagePercentage% und ist über dem Grenzwert!"
    } 

    # Warte 1 Sekunden, bevor erneut geprüft wird
    Start-Sleep -Seconds 1
}
