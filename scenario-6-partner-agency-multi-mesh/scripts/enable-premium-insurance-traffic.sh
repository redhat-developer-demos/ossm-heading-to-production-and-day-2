#!/bin/bash

NAMESPACE=$1
SM_CP_NS=$2
DOMAIN_NAME=$3 #eg. apps.ocp4.example.com
PREFIX=$4

echo '---------------------------------------------------------------------------'
echo 'Partner Environment                        : '$NAMESPACE
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'CLUSTER DOMAIN NAME		                     : '$DOMAIN_NAME
echo 'PREFIX                                     : '$PREFIX
echo '---------------------------------------------------------------------------'

sleep 5

echo "--------------------------------"
echo "HTTP Gateway"
echo "--------------------------------"
echo
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: $PREFIX-gateway
  namespace: $SM_CP_NS
spec:
  servers:
    - port:
        number: 8080
        protocol: HTTP
        name: http
      hosts:
        - istio-ingressgateway-$SM_CP_NS.$DOMAIN_NAME
  selector:
    istio: ingressgateway"


echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: $PREFIX-gateway
  namespace: $SM_CP_NS
spec:
  servers:
    - port:
        number: 8080
        protocol: HTTP
        name: http
      hosts:
        - istio-ingressgateway-$SM_CP_NS.$DOMAIN_NAME
  selector:
    istio: ingressgateway"| oc apply -f -


echo "--------------------------------"
echo "VirtualService"
echo "--------------------------------"
echo
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: vs-parner-insurance
  namespace: $NAMESPACE
spec:
  hosts:
    - istio-ingressgateway-$SM_CP_NS.$DOMAIN_NAME
  gateways:
    - $SM_CP_NS/$PREFIX-gateway
  http:
    - match:
        - uri:
            exact: /insurances
        - uri:
            prefix: /insurances
      route:
        - destination:
            host: insurances.$NAMESPACE.svc.cluster.local
          weight: 100"

echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: vs-parner-insurance
  namespace: $NAMESPACE
spec:
  hosts:
    - istio-ingressgateway-$SM_CP_NS.$DOMAIN_NAME
  gateways:
    - $SM_CP_NS/$PREFIX-gateway
  http:
    - match:
        - uri:
            exact: /insurances
        - uri:
            prefix: /insurances
      route:
        - destination:
            host: insurances.$NAMESPACE.svc.cluster.local
          weight: 100"|oc apply -f -

echo
sleep 5
echo
echo "Check Premium Insurance Service over HTTP"
echo "-----------------------------------------------------"
echo
echo "http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/insurances/London"
echo
sleep 5
curl -i http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/insurances/London
sleep 3
echo "----------------"
curl -i http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/insurances/Munich
sleep 3
echo "----------------"
curl -i http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/insurances/Rome
sleep 3
echo "----------------"
curl -i http://$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)/insurances/Paris
