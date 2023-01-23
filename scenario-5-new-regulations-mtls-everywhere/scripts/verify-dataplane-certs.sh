#!/bin/bash

echo "###########################"
echo " CERTS CHECK ON DATAPLANE"
echo "###########################"
echo
echo "1. Sleep 20 seconds for the mTLS policy to take effect before retrieving the certificate chain of cars POD. As the CA certificate used in this example is self-signed, the verify error:num=19:self signed certificate in certificate chain error returned by the openssl command is expected."
echo "------------------------------------------------------" 
sleep 2

oc exec "$(oc get pod -l app=travels -n prod-travel-agency -o jsonpath={.items..metadata.name})" -c istio-proxy -n prod-travel-agency -- openssl s_client -showcerts -connect $(oc -n prod-travel-agency get svc cars -o jsonpath={.spec.clusterIP}):8000 > cars-cert.txt

echo 
echo "2. Parse the certificates on the certificate chain."
echo "------------------------------------------------------"
sed -n '/-----BEGIN CERTIFICATE-----/{:start /-----END CERTIFICATE-----/!{N;b start};/.*/p}' cars-cert.txt > certs.pem
awk 'BEGIN {counter=0;} /BEGIN CERT/{counter++} { print > "proxy-cert-" counter ".pem"}' < certs.pem

echo
echo "3. Verify the root certificate used in the POD handshake is the same as the one specified by the OSSM administrator:"
echo "------------------------------------------------------" 
openssl x509 -in ../certs-resources/certs/ca.cert.pem -text -noout > /tmp/root-cert.crt.txt
openssl x509 -in ./proxy-cert-3.pem -text -noout > /tmp/pod-root-cert.crt.txt
diff -s /tmp/root-cert.crt.txt /tmp/pod-root-cert.crt.txt


echo
echo "4. Verify the Intermediate CA certificate used in the POD handshake is the same as the one specified by the OSSM administrator:"
echo "------------------------------------------------------" 
openssl x509 -in ../certs-resources/intermediate/certs/intermediate.cert.pem -text -noout > /tmp/ca-cert.crt.txt
openssl x509 -in ./proxy-cert-2.pem -text -noout > /tmp/pod-cert-chain-ca.crt.txt
diff -s /tmp/ca-cert.crt.txt /tmp/pod-cert-chain-ca.crt.txt

echo
echo "5. Verify the certificate chain from the root certificate to the workload certificate:"
echo "------------------------------------------------------" 
openssl verify -CAfile <(cat ../certs-resources/intermediate/certs/intermediate.cert.pem ../certs-resources/certs/ca.cert.pem) ./proxy-cert-1.pem
