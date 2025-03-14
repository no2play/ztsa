# Disable IPv6 on all network adapters
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
$regName = "DisabledComponents"
$regValue = 0xFF

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord
Write-Output "IPv6 has been disabled. A restart is required for changes to take effect."

# Add authproxy.example.com to Local Intranet Zone
$zoneRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\authproxy.example.com"
if (-not (Test-Path $zoneRegistryPath)) {
    New-Item -Path $zoneRegistryPath -Force | Out-Null
}
Set-ItemProperty -Path $zoneRegistryPath -Name "*" -Value 1 -Type DWord
Write-Output "Added authproxy.example.com to the Local Intranet zone."

# Force refresh of Internet Explorer settings (optional)
RUNDLL32.EXE inetcpl.cpl,ClearMyTracksByProcess 1
