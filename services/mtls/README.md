# mTLS

This example will generally follow [this guide](https://medium.com/geekculture/mtls-with-nginx-and-nodejs-e3d0980ed950)

An explanation of CA certs and certs/keys is available [here](http://www.steves-internet-guide.com/ssl-certificates-explained/)

### Running the example

All certificates will need to be generated. This includes:
- the Certificate Authority cert and key
- a server key and cert for the usual server side TLS
- a client key and cert for the client side TLS

This is all wrapped up in a shell script
```
make-certs.sh
```
An nginx server can then ne brought up (which mounts the relevant certs and keys)
```
docker-compose build
docker-compose up
```
One can then make a `curl` command using client side certs and the CA cert.
This is all wrapped up in a shell script
```
run-curl-command.sh
```