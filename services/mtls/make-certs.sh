#!/bin/bash

# Make the certificates for the overall Certificate Authority (CA).
# This will represent the body/authority for authorizing all
# Certificate Signing Requests (CSR)
openssl req \
  -newkey rsa:4096 \
  -x509 \
  -keyout ca.key \
  -out ca.crt \
  -days 30 \
  -nodes \
  -subj "/CN=my_awesome_ca"

# Create a new private key for the nginx server, and a corresponding CSR
openssl req \
  -newkey rsa:4096 \
  -keyout server.key \
  -out server.csr \
  -nodes \
  -days 30 \
  -subj "/CN=localhost"

# submit the CSR to the CA, and get a server certificate for the nginx server
openssl x509 \
  -req \
  -in server.csr \
  -out server.crt \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -days 30

# For TLS, only the server needs a cert and key. The client only needs
# to know the certificate that the server has been signed against
# (which contains the public key), and has been issued by the CA.
# This would be the ca.crt file generated on the first line.

# For mTLS, the client needs a cert and key as well.
# Create a new private key for the client, and a corresponding CSR
openssl req \
  -newkey rsa:4096 \
  -keyout client.key \
  -out client.csr \
  -nodes \
  -days 30 \
  -subj "/CN=client"

# submit the CSR to the CA, and get a certificate for the client
openssl x509 \
  -req \
  -in client.csr \
  -out client.crt \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -days 30

# debug
for f in $(ls *.crt) do
    openssl x509 -in ${f} -text -noout
done
