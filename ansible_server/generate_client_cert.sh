#/bin/bash

# generate the certs
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out client_cert.pem -outform PEM -keyout client_key.pem -subj "/CN=ansiblerunner" -extensions v3_req_client
