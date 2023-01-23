#!/bin/bash

echo "###########################"
echo "CERTS CHECK ON CONTROLPLANE"
echo "###########################"

echo
echo "1. Get the ceritificates used between istio-ingressgateway and istiod"
oc exec "$(oc get pod -l app=istio-ingressgateway -n prod-istio-system -o jsonpath={.items..metadata.name})" -c istio-proxy -n prod-istio-system -- openssl s_client -showcerts -connect $(oc get svc istiod-production -o jsonpath={.spec.clusterIP}):15012 > istiod-cert.txt
sed -n '/-----BEGIN CERTIFICATE-----/{:start /-----END CERTIFICATE-----/!{N;b start};/.*/p}' istiod-cert.txt > certs-cp.pem
awk 'BEGIN {counter=0;} /BEGIN CERT/{counter++} { print > "proxy-cp-cert-" counter ".pem"}' < certs-cp.pem

echo
echo "2. Verify the root certificate used in the istiod handshake is the same as the one specified by the OSSM administrator:"
echo "------------------------------------------------------" 
openssl x509 -in ../certs-resources/certs/ca.cert.pem -text -noout > /tmp/root-cert.crt.txt
openssl x509 -in ./proxy-cp-cert-3.pem -text -noout > /tmp/pod-root-cp-cert.crt.txt
diff -s /tmp/root-cert.crt.txt /tmp/pod-root-cp-cert.crt.txt


echo
echo "4. Verify the Intermediate CA certificate used in the istiod handshake is the same as the one specified by the OSSM administrator:"
echo "------------------------------------------------------" 
openssl x509 -in ../certs-resources/intermediate/certs/intermediate.cert.pem -text -noout > /tmp/ca-cert.crt.txt
openssl x509 -in ./proxy-cp-cert-2.pem -text -noout > /tmp/pod-cert-cp-chain-ca.crt.txt
diff -s /tmp/ca-cert.crt.txt /tmp/pod-cert-cp-chain-ca.crt.txt

echo
echo "5. Verify the certificate chain from the root certificate to the workload certificate:"
echo "------------------------------------------------------" 
openssl verify -CAfile <(cat ../certs-resources/intermediate/certs/intermediate.cert.pem ../certs-resources/certs/ca.cert.pem) ./proxy-cp-cert-1.pem

