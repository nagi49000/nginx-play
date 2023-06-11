#!/bin/bash
set -eux

# this guide follows https://www.golinuxcloud.com/renew-expired-root-ca-certificate-openssl/

SCRIPT_DIR=`realpath $(dirname $0)`
cd ${SCRIPT_DIR}/certs-folder/server

# check the current validity dates of the server cert
openssl x509 -noout -text -in server.crt | grep 'GMT'

# create a new CSR based on the existing cert and key
openssl x509 -x509toreq -in server.crt -signkey server.key -out new-server.csr

# have the original issuing CA re-issue a new cert
openssl ca \
  -batch \
  -config ${SCRIPT_DIR}/certs-folder/intermediateCA/openssl_intermediate.cnf \
  -extensions server_cert \
  -days 30 \
  -notext \
  -md sha256 \
  -in new-server.csr \
  -out new-server.crt
chmod 444 server.crt
openssl x509 -noout -text -in new-server.crt | grep 'GMT'
