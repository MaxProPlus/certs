#!/usr/bin/env bash

configFile="req.cnf"

caCertPath="../ca/ca.crt"
caKeyPath="../ca/id_rsa"
serialPath="./site.srl"

keyPath="id_rsa"
csrPath="site.csr"
crtPath="site.crt"

cat > "$configFile" << END
[req]
distinguished_name=dn
prompt=no

[dn]
C=US
ST=Web
O=MyFutureCompany
CN=site.loc

[v3]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = site.loc
IP.1 = 127.0.0.1
END

if [ ! -f "$keyPath" ]; then
  echo 'Generating private key...'
  openssl genrsa -out "$keyPath" 4096
fi

echo 'Generating csr...'
openssl req -new -key "$keyPath" -out "$csrPath" -config "$configFile"

echo 'Generating Self-Signed cert...'
if [ -f "$serialPath" ]; then
  openssl x509 -req -in "$csrPath" -days 1825 -CA "$caCertPath" -CAkey "$caKeyPath" -CAserial "$serialPath" \
    -out "$crtPath" -extfile "$configFile" -extensions v3
else
  openssl x509 -req -in "$csrPath" -days 1825 -CA "$caCertPath" -CAkey "$caKeyPath" -CAcreateserial -CAserial "$serialPath" \
    -out "$crtPath" -extfile "$configFile" -extensions v3
fi
