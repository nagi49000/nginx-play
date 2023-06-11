#!/bin/bash
set -eux
# once nginx is running via the docker-compose, this curl command should contact it using the generated certs
curl --cacert ./certs-folder/intermediateCA/certs/ca-chain.cert https://localhost:8443
