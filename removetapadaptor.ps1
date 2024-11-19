# Elevate PowerShell to run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Relaunching PowerShell as Administrator..."
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Navigate to the folder
$Path = "C:\Program Files\Trend Micro\ZTSA\tun_init"
if (Test-Path $Path) {
    Set-Location -Path $Path
} else {
    Write-Host "Path $Path does not exist. Exiting..." -ForegroundColor Red
    exit
}

# Execute the tapctl.exe list command and capture output
$listOutput = & .\tapctl.exe list

if ($listOutput) {
    Write-Host "Connections found:"
    Write-Host $listOutput

    # Extract connection names from the output
    $connections = $listOutput -split "`n" | ForEach-Object { $_ -match '"(Local Area Connection[^"]*)"' | Out-Null; $matches[1] }

    if ($connections) {
        foreach ($connection in $connections) {
            Write-Host "Deleting $connection..."
            & .\tapctl.exe delete $connection
        }
        Write-Host "All connections deleted successfully."
    } else {
        Write-Host "No connections found to delete." -ForegroundColor Yellow
    }
} else {
    Write-Host "No output from tapctl.exe list. Exiting..." -ForegroundColor Yellow
}
