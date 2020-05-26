# Start the WinRM service and enable automatic boot
Set-Service -Name "WinRM" -StartupType Automatic
Start-Service -Name "WinRM"

# Ensure PowerShell remoting is enabled
if (-not (Get-PSSessionConfiguration) -or (-not (Get-ChildItem WSMan:\localhost\Listener))) {
    Enable-PSRemoting -SkipNetworkProfileCheck -Force
}