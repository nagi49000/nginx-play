#!/bin/bash
set -eux

# this guide follows https://www.golinuxcloud.com/openssl-create-certificate-chain-linux/

# all certs will be made in this folder. To clear all certs created,
# delete the following folder
cd `dirname $0`
mkdir -p certs-folder/{rootCA,intermediateCA}/{certs,crl,newcerts,private}
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

# create the root CA key
openssl genrsa -out rootCA/private/ca.key 4096
chmod 400 rootCA/private/ca.key
openssl rsa -noout -text -in rootCA/private/ca.key # stdout debug on key
