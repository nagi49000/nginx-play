# Root CA

This example will generally follow [this excellent guide](https://www.golinuxcloud.com/openssl-create-certificate-chain-linux). Generally,
that section on golinuxcloud has far more details than are covered here.

More details on nginx configuration are available on the [nginx docs pages](http://nginx.org/en/docs/http/configuring_https_servers.html)

An explanation of CA certs and certs/keys is available [here](http://www.steves-internet-guide.com/ssl-certificates-explained/)

### Running the example from cold

All certificates will need to be generated. This includes:
- the Root Certificate Authority cert and key
- an intermediate Certificate Authority cert and key
- a server key and cert for the usual server side TLS

This is all wrapped up in a couple of shell scripts. `init-certs.sh` will create a directory structure under a new folder, `certs-folder`,
for the root CA, intermediate CA, and server, along with openssl configs for the root and intermediate CAs, and keys for root, intermediate and server.
In this example, there is only one intermediate and one server, but hopefully the reader will be able to extrapolate to multiple intermediate CAs
under the root CA, and multiple servers under the intermediate CA. Also, the notion of the root CA, intermediate CA and server (for tutorial purposes)
happen to just be separate folders under `certs-folder`. In practice these would be separate machines/environments with CSRs passed between them;
again, hopefully an extrapolation the reader can make.

The actual certs, as a one-off 'big-bang', are all generated under `make-certs.sh`. The shell script is reasonably well factored into 3 sections;
provisioning root, provisioning intermediate and provisioning server; so if these operations need to be performed at different times, hopefully it
is clear to the reader how to partition the script and commands. There is also some checking of certificate chains as debug, which
[this page](https://www.howtouselinux.com/post/exploring-unable-to-get-local-issuer-certificate) covers in more detail.

An nginx server can then be brought up (which mounts the relevant server certs and keys) `docker-compose up --build`.

One can then make a `curl` command to the running nginx server, using the CA certs for the root and intermediate.
This is all wrapped up in a shell script `run-curl-command.sh`.

# Revoking a certificate before the expiration date of the certificate

If one wishes, the certificate from an issuer can be revoked before the expiration date of the certificate. An example of this is in `revoke-cert.sh`.