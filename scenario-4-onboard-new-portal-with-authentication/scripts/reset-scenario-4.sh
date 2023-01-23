#!/bin/bash

echo
echo "---------------------------------------------"
echo "Cluster Admin Resets"
echo "---------------------------------------------"
./login-as.sh phillip
oc delete project rhsso
oc -n prod-istio-system set volume deployment/istiod-production --remove --name=extracacerts --containers=discovery
oc -n prod-istio-system delete RequestAuthentication jwt-rhsso-gto-external
oc -n prod-istio-system delete AuthorizationPolicy authpolicy-gto-external

echo
echo "---------------------------------------------"
echo "Mesh Dev Farid (Travel Services Domain) Reset"
echo "---------------------------------------------"
./login-as.sh farid
oc delete vs travel-api -n prod-travel-agency

echo
echo
echo "----------------------------------------"
echo "Mesh Operator emma SMCP Reset & secret with certs"
echo "----------------------------------------"
./login-as.sh emma
rm car-root.crt curl-client.crt gto-external-app.crt
rm curl-client.csr gto-external-app.csr
rm *.key
rm ca-root.srl
rm car-root.key curl-client.key gto-external-app.key
oc -n prod-istio-system delete secret/gto-external-secret

oc -n prod-istio-system delete route/gto-external
oc -n prod-istio-system delete gateway/travel-api-gateway
oc -n $SM_CP_NS delete secret/gto-external-secret
