# Load Web Assembly
Add-Type -AssemblyName 'System.Web'

# Min/Max Password Characters
$minChar = 10 
$maxChar = 16
$len = Get-Random -Minimum $minChar -Maximum $maxChar
$symbols = 6
$password = [System.Web.Security.Membership]::GeneratePassword($len, $symbols)

# Create Ansible user
$ansibleRunnerUsername = 'ansiblerunner'
$ansibleRunnerPassword = (ConvertTo-SecureString -String $password -AsPlainText -Force)
if (-not (Get-LocalUser -Name $ansibleRunnerUsername -ErrorAction Ignore)) {
    $newUserParams = @{
        Name                 = $ansibleRunnerUsername
        AccountNeverExpires  = $true
        PasswordNeverExpires = $true
        Password             = $ansibleRunnerPassword
    }
    $null = New-LocalUser @newUserParams
}

# Add the local user to the administrator's group. 
Get-LocalUser -Name $ansibleRunnerUsername | Add-LocalGroupMember -Group 'Administrators'

# Allow WinRM with User Account Control
$newItemParams = @{
    Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Name         = 'LocalAccountTokenFilterPolicy'
    Value        = 1
    PropertyType = 'DWORD'
    Force        = $true
}
$null = New-ItemProperty @newItemParams

# Map generated certificates to the ansible runner
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ansibleRunnerUsername, $ansibleRunnerPassword

# Find the cert thumbprint for the client certificate created on the Ansible host
$ansibleCert = Get-ChildItem -Path 'Cert:\LocalMachine\Root' | Where-Object {$_.Subject -eq 'CN=ansiblerunner'}

$params = @{
	Path = 'WSMan:\localhost\ClientCertificate'
	Subject = "$ansibleRunnerUsername@localhost"
	URI = '*'
	Issuer = $ansibleCert.Thumbprint
  Credential = $credential
	Force = $true
}
New-Item @params