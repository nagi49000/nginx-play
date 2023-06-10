#!/bin/bash
set -eux

# this guide follows https://www.golinuxcloud.com/openssl-create-certificate-chain-linux/

# all certs will be made in this folder. To clear all certs created,
# delete the following folder
SCRIPT_DIR=`realpath $(dirname $0)`

cd ${SCRIPT_DIR}
mkdir -p certs-folder/{rootCA,intermediateCA}/{certs,crl,newcerts,private}
mkdir -p certs-folder/server
cd certs-folder

# initialise serial numbers for CAs; these increment as certificates are generated for cert tracking
echo 1000 > rootCA/serial
echo 1000 > intermediateCA/serial

# initialise the crl (Certificate Revocation List) number to some meaningless number (this tracks the
# latest CRL issued; so when no CRLs have been issued, this number is meaningless)
echo 0100 > rootCA/crlnumber
echo 0100 > intermediateCA/crlnumber

# create empty files for keeping a track of certs generated. Empty since nothing generated yet.
touch rootCA/index.txt
touch intermediateCA/index.txt

# configure the config files for rootCA and intermediateCA from template
sed "s:REPLACE_WITH_INSTALL_LOCATION:${SCRIPT_DIR}:g" ${SCRIPT_DIR}/templates/openssl_root.cnf.template > ${SCRIPT_DIR}/certs-folder/rootCA/openssl_root.cnf
sed "s:REPLACE_WITH_INSTALL_LOCATION:${SCRIPT_DIR}:g" ${SCRIPT_DIR}/templates/openssl_intermediate.cnf.template > ${SCRIPT_DIR}/certs-folder/intermediateCA/openssl_intermediate.cnf

# create the root CA key
openssl genrsa -out rootCA/private/ca.key 4096
# chmod 400 rootCA/private/ca.key
# openssl rsa -noout -text -in rootCA/private/ca.key # stdout debug on key

# create the intermediate CA key. There can be multiple intermediate CAs
openssl genrsa -out intermediateCA/private/ca.key 4096
# chmod 400 intermediateCA/private/ca.key
# openssl rsa -noout -text -in intermediateCA/private/ca.key # stdout debug on key

# create a key for the nginx webserver. In general there will be multiple servers.
openssl genrsa -out server/server.key 4096
# chmod 400 server/server.key
# openssl rsa -noout -text -in server/server.key # stdout debug on key
