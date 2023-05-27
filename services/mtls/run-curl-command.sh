#!/bin/bash
set -eux

curl https://localhost:8443 \
     --cacert ./certs-folder/ca.crt \
     --key certs-folder/client.key \
     --cert certs-folder/client.crt
