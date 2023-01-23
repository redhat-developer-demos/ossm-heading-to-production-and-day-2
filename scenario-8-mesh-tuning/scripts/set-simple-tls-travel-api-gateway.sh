#!/bin/bash

CLUSTER_NAME=$1
DOMAIN_NAME=$2


echo '--------------------------------------------------'
echo 'SCLUSTER_NAME        : '$SM_CP_NS
echo 'DOMAIN_NAME          : '$DOMAIN_NAME
echo '--------------------------------------------------'


echo "======================================================================================================="   
echo " Saving production ready config for Gateway: travel-api-gateway at >> travel-api-gateway-prodsetup.yaml"
echo "======================================================================================================="   
echo
oc get gw travel-api-gateway -n prod-istio-system -o yaml > travel-api-gateway-prodsetup.yaml   

echo
echo "======================================================================================================="   
echo " Relax MUTUAL TLS for production ready config for Gateway: travel-api-gateway"
echo "======================================================================================================="   
echo
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: travel-api-gateway
  namespace: prod-istio-system
spec:
  servers:
    - port:
        number: 443
        protocol: HTTPS
        name: https
      hosts:
        - gto-external-prod-istio-system.apps.ocp4.rhlab.de
      tls:
        mode: SIMPLE
        credentialName: gto-external-secret
  selector:
    app: gto-external-ingressgateway "
    
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: travel-api-gateway
  namespace: prod-istio-system
spec:
  servers:
    - port:
        number: 443
        protocol: HTTPS
        name: https
      hosts:
        - gto-external-prod-istio-system.apps.$CLUSTER_NAME.$DOMAIN_NAME
      tls:
        mode: SIMPLE
        credentialName: gto-external-secret
  selector:
    app: gto-external-ingressgateway " |oc apply -f -
