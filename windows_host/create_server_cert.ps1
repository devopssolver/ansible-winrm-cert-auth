# Get the current Hostname
$hostname = hostname

# Generate the server cert
$serverCert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation 'Cert:\LocalMachine\My'

