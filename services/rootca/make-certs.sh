#!/bin/bash
set -eux

# this guide follows https://www.golinuxcloud.com/openssl-create-certificate-chain-linux/

SCRIPT_DIR=`realpath $(dirname $0)`
cd ${SCRIPT_DIR}

# create the root CA, with all the subj fields populated as per the policy in openssl_root.conf
cd ${SCRIPT_DIR}/certs-folder/rootCA
openssl req \
  -config openssl_root.cnf \
  -key private/ca.key \
  -new \
  -x509 \
  -days 7300 \
  -sha256 \
  -extensions v3_ca \
  -out certs/ca.cert \
  -subj "/C=US/ST=California/O=Example Corp/CN=My Awesome Root CA"
chmod 444 certs/ca.cert
openssl x509 -noout -text -in certs/ca.cert
cd ${SCRIPT_DIR}

# ---
# create the intermediate CA, with all the subj fields populated as per the policy in openssl_root.conf
# first by making the CSR (cert sign request) ...
cd ${SCRIPT_DIR}/certs-folder/intermediateCA
openssl req \
  -config openssl_intermediate.cnf \
  -key private/ca.key \
  -new \
  -sha256 \
  -out certs/ca.csr \
  -subj "/C=US/ST=California/O=Example Corp/CN=My Awesome Intermediate CA"

# ... and then getting the root CA to sign the request, and give a cert
openssl ca \
  -batch \
  -config ${SCRIPT_DIR}/certs-folder/rootCA/openssl_root.cnf \
  -extensions v3_intermediate_ca \
  -days 3650 \
  -notext \
  -md sha256 \
  -in certs/ca.csr \
  -out certs/ca.cert
chmod 444 certs/ca.cert
openssl x509 -noout -text -in certs/ca.cert

# note that there should now be changes and entries in:
#   certs-folder/rootCA/index.txt
#   certs-folder/rootCA/serial
cd ${SCRIPT_DIR}

# ---
# make a cert chain by bundling all CA certs together
cd ${SCRIPT_DIR}/certs-folder
cat intermediateCA/certs/ca.cert rootCA/certs/ca.cert > ca-chain.cert
cd ${SCRIPT_DIR}

# ---
# create the server cert from the intermediate CA
# first by making the CSR (cert sign request) ...
cd ${SCRIPT_DIR}/certs-folder/server
openssl req \
  -key server.key \
  -out server.csr \
  -new \
  -sha256 \
  -subj "/CN=localhost"

# ... and then having intermediate CA to sign the CSR and give a cert for the server
openssl ca \
  -batch \
  -config ${SCRIPT_DIR}/certs-folder/intermediateCA/openssl_intermediate.cnf \
  -extensions server_cert \
  -days 30 \
  -notext \
  -md sha256 \
  -in server.csr \
  -out server.crt
chmod 444 server.crt
openssl x509 -noout -text -in server.crt

# make a full server bundle for mounting in nginx. Note the order of certs
cat \
  server.crt \
  ${SCRIPT_DIR}/certs-folder/intermediateCA/certs/ca.cert \
  ${SCRIPT_DIR}/certs-folder/rootCA/certs/ca.cert \
  > fullchain.crt
chmod 444 fullchain.crt
openssl x509 -noout -text -in fullchain.crt
cd ${SCRIPT_DIR}

# check the certificate chain is ok
# openssl verify -CAfile certs-folder/rootCA/certs/ca.cert certs-folder/intermediateCA/certs/ca.cert
# openssl verify -CAfile certs-folder/ca-chain.cert certs-folder/server/server.crt
cd ${SCRIPT_DIR}/certs-folder
openssl verify -CAfile \
  rootCA/certs/ca.cert \
  intermediateCA/certs/ca.cert \
  server/server.crt
