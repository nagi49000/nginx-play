#!/bin/bash
set -eux

cd `dirname $0`
sleep 2
ls
curl https://localhost:8443 \
     --cacert ./certs-folder/ca.crt \
     --key ./certs-folder/client.key \
     --cert ./certs-folder/client.crt
