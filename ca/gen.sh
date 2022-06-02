#!/usr/bin/env bash

configFile="req.cnf"

keyPath="id_rsa"
csrPath="ca.csr"
crtPath="ca.crt"

cat > "$configFile" << END
[req]
distinguished_name=dn
prompt=no

[dn]
C=US
ST=Web
O=MyFutureCompany
CN=myCA

[v3]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints=critical, CA:true
keyUsage = digitalSignature, cRLSign, keyCertSign
END

if [ ! -f "$keyPath" ]; then
  echo 'Generating private key...'
  openssl genrsa -out "$keyPath" 4096
fi

echo 'Generating csr...'
openssl req -new -key "$keyPath" -out "$csrPath" -config "$configFile"

echo 'Generating Self-Signed cert...'
openssl x509 -req -in "$csrPath" -signkey "$keyPath" -days 1825 -out "$crtPath" -extfile "$configFile" -extensions v3
