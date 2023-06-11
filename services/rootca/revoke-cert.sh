#!/bin/bash
set -eux

# this guide follows https://www.golinuxcloud.com/openssl-create-certificate-chain-linux/

SCRIPT_DIR=`realpath $(dirname $0)`
cd ${SCRIPT_DIR}/certs-folder

# Revoke the server cert. Since the server cert was issued by the intermediate CA,
# the intermediate CA will be used to revoke the server cert.
# Similarly, the intermediate cert can also be revoked by the root CA
openssl ca -config intermediateCA/openssl_intermediate.cnf -revoke server/server.crt

# update the Certificate Revocation List (CRL) for the intermediate CA
openssl ca -config intermediateCA/openssl_intermediate.cnf -gencrl -out intermediateCA/crl/intermediate.crl.pem

# Note that this should now have updated the files
#   intermediateCA/index.txt
#   intermediateCA/crlnumber

# get a list of all revoked certificates on the intermediate CA
openssl crl -in intermediateCA/crl/intermediate.crl.pem -text -noout
