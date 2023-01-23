#!/bin/bash

SM_CP_NS=$1
ISTIO_INGRESS_ROUTE_URL=$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'Remote SMCP Route Name (when NO DNS)       : '$ISTIO_INGRESS_ROUTE_URL
echo '---------------------------------------------------------------------------'

sleep 5

echo
echo
echo "Apply initial Istio Configs to Route external Traffic via Service Mesh Ingress"
echo "---------------------------------------------------------------------------------"

echo "Service Mesh Ingress Gateway Route"
echo "Ingress Route [$ISTIO_INGRESS_ROUTE_URL]"
echo
                
echo
echo                
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: control-gateway
  namespace: $SM_CP_NS
spec:
  servers:
    - hosts:
        - $ISTIO_INGRESS_ROUTE_URL
      port:
        name: http
        number: 80
        protocol: HTTP
  selector:
    istio: ingressgateway"
    
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: control-gateway
  namespace: $SM_CP_NS
spec:
  servers:
    - hosts:
        - $ISTIO_INGRESS_ROUTE_URL
      port:
        name: http
        number: 80
        protocol: HTTP
  selector:
    istio: ingressgateway"|oc apply -f -
