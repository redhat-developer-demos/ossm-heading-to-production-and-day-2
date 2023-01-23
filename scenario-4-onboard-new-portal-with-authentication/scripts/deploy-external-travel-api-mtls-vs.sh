#!/bin/bash

ENV=$1
SM_CP_NS=$2
PREFIX=gto-external


https_mutual_route=$(oc get route $PREFIX -o jsonpath='{.spec.host}' -n $SM_CP_NS)
echo https_mutual_route:  $https_mutual_route
echo
sleep 3
echo
echo
echo "Apply Istio Virtual Service Config to Route external GTO Traffic via Service Mesh Ingress to Travel Services"
echo "------------------------------------------------------------------------------------------------------------"
echo
echo "Service Mesh Ingress Gateway Route"

echo "Ingress Route [https://$https_mutual_route]"
echo
sleep 3
echo
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: travel-api
  namespace: $ENV-travel-agency
spec:
  hosts:
    - $https_mutual_route
  gateways:
    - $SM_CP_NS/travel-api-gateway
  http:
    - match:
        - uri:
            exact: /flights
        - uri:
            prefix: /flights
      route:
        - destination:
            host: flights.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /hotels
        - uri:
            prefix: /hotels
      route:
        - destination:
            host: hotels.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /cars
        - uri:
            prefix: /cars
      route:
        - destination:
            host: cars.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /insurances
        - uri:
            prefix: /insurances
      route:
        - destination:
            host: insurances.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /travels
        - uri:
            prefix: /travels
      route:
        - destination:
            host: travels.$ENV-travel-agency.svc.cluster.local
          weight: 100"

echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: travel-api
  namespace: $ENV-travel-agency
spec:
  hosts:
    - $https_mutual_route
  gateways:
    - $SM_CP_NS/travel-api-gateway
  http:
    - match:
        - uri:
            exact: /flights
        - uri:
            prefix: /flights
      route:
        - destination:
            host: flights.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /hotels
        - uri:
            prefix: /hotels
      route:
        - destination:
            host: hotels.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /cars
        - uri:
            prefix: /cars
      route:
        - destination:
            host: cars.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /insurances
        - uri:
            prefix: /insurances
      route:
        - destination:
            host: insurances.$ENV-travel-agency.svc.cluster.local
          weight: 100
    - match:
        - uri:
            exact: /travels
        - uri:
            prefix: /travels
      route:
        - destination:
            host: travels.$ENV-travel-agency.svc.cluster.local
          weight: 100"|oc apply -f -

sleep 10
echo
echo
echo "GTO mTLS Traffic via Service Mesh Ingress to Travel Services"
echo "------------------------------------------------------------------------------------------------------------------"
echo

place="Warsaw"
echo "----- External (GTO) Travel Search for [$place] ------------------------------------------------------------------"
call-via-mtls-travel-agency-api.sh https://$https_mutual_route $place
echo
place="Brussels"
echo "----- External (GTO) Travel Search for [$place] ------------------------------------------------------------------"
call-via-mtls-travel-agency-api.sh https://$https_mutual_route $place
echo
#place="Tallinn"
#echo "----- External (GTO) Travel Search for [$place] ------------------------------------------------------------------"
#call-via-mtls-travel-agency-api.sh https://$https_mutual_route $place
#echo
echo

