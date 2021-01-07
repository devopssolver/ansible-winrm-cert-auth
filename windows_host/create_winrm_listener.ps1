########################################################################
#
# WARNING: This script will delete and recreate the WINRM Https listener 
# 
########################################################################

# Get the current Hostname
$hostname = hostname

# Get the server certificate generated previously
$serverCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.DnsNameList -contains $hostname} 

# Find all HTTPS listners
$httpsListeners = Get-ChildItem -Path WSMan:\localhost\Listener\ | where-object { $_.Keys -match 'Transport=HTTPS' }

# Remove listener
if ($httpsListeners){
    $selectorset = @{
        Address = "*"
        Transport = "HTTPS"
    }
    Remove-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset
}

# Create a new listener
$newWsmanParams = @{
    ResourceUri = 'winrm/config/Listener'
    SelectorSet = @{ Transport = "HTTPS"; Address = "*" }
    ValueSet    = @{ Hostname = $hostName; CertificateThumbprint = $serverCert.Thumbprint }
    # UseSSL = $true
}
$null = New-WSManInstance @newWsmanParams

# set to certificate authentication
winrm set WinRM/Config/Client/Auth '@{Basic="false";Digest="false";Kerberos="false";Negotiate="true";Certificate="true";CredSSP="false"}'

# enable winrm service certificate auth
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
