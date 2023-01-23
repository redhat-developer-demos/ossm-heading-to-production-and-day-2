#!/bin/bash

POLICY=$1
SM_CP_NS=$2 #eg. prod-istio-system
CLUSTERNAME=$3 #eg. ocp4
BASEDOMAIN=$4 #eg. example.com
CERTS_LOCATION=../scenario-4-onboard-new-portal-with-authentication

echo "####################################################################"
echo "#                                                                  #"
echo "#           CHECKING $POLICY ALL AUTHZ DEFAULT POLICY                #"
echo "#                                                                  #"
echo "####################################################################"

#echo "---------------------------------------------------------------------------------------"
GATEWAY_URL=$(oc get route gto-external -o jsonpath='{.spec.host}' -n $SM_CP_NS)
#echo GATEWAY_URL:  $GATEWAY_URL
echo
TOKEN=$(curl -sLk --data "username=gtouser&password=gtouser&grant_type=password&client_id=istio&client_secret=bcd06d5bdd1dbaaf81853d10a66aeb989a38dd51" https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/realms/servicemesh-lab/protocol/openid-connect/token | jq .access_token)
#echo TOKEN: $TOKEN
#echo "---------------------------------------------------------------------------------------"
echo

travels=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Tallinn |jq)
cars=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Tallinn |jq)
flights=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Tallinn |jq)
insurances=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Tallinn |jq)
hotels=$(curl -s -o /dev/null -w "%{http_code}" -X GET --cacert $CERTS_LOCATION/ca-root.crt --key $CERTS_LOCATION/curl-client.key --cert $CERTS_LOCATION/curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Tallinn |jq)

echo "Authorization $SM_CP_NS --> prod-travel-agency"
echo "-------------------------------------------------------------------"

if [[ $travels -eq 200 ]]
then
  echo "[ALLOW] gto-external-ingressgateway --> travels.prod-travel-agency"
else
  echo "[DENY] gto-external-ingressgateway --> travels.prod-travel-agency"
fi
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] gto-external-ingressgateway --> cars.prod-travel-agency"
else
  echo "[DENY] gto-external-ingressgateway --> cars.prod-travel-agency"
fi
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] gto-external-ingressgateway --> flights.prod-travel-agency"
else
  echo "[DENY] gto-external-ingressgateway --> flights.prod-travel-agency"
fi
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] gto-external-ingressgateway --> insurances.prod-travel-agency"
else
  echo "[DENY] gto-external-ingressgateway --> insurances.prod-travel-agency"
fi
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] gto-external-ingressgateway --> hotels.prod-travel-agency"
else
  echo "[DENY] gto-external-ingressgateway --> hotels.prod-travel-agency"
fi


echo
echo "Authorization prod-travel-control --> prod-travel-agency"
echo "-------------------------------------------------------------------"
podname=$(oc get pods -n prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 5
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] control.prod-travel-control --> travels.prod-travel-agency"
else
  echo "[DENY] control.prod-travel-control --> travels.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 5
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] control.prod-travel-control --> cars.prod-travel-agency"
else
  echo "[DENY] control.prod-travel-control --> cars.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 5
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] control.prod-travel-control --> flights.prod-travel-agency"
else
  echo "[DENY] control.prod-travel-control --> flights.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 5
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] control.prod-travel-control --> insurances.prod-travel-agency"
else
  echo "[DENY] control.prod-travel-control --> insurances.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-control | grep control | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n prod-travel-control -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 5
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] control.prod-travel-control --> hotels.prod-travel-agency"
else
  echo "[DENY] control.prod-travel-control --> hotels.prod-travel-agency"
fi

echo
echo "Authorization prod-travel-portal --> prod-travel-agency"
echo "-------------------------------------------------------------------"

podname=$(oc get pods -n prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 5
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] viaggi.prod-travel-portal --> travels.prod-travel-agency"
else
  echo "[DENY] viaggi.prod-travel-portal --> travels.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 5
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] viaggi.prod-travel-portal --> cars.prod-travel-agency"
else
  echo "[DENY] viaggi.prod-travel-portal --> cars.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 5
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] viaggi.prod-travel-portal --> flights.prod-travel-agency"
else
  echo "[DENY] viaggi.prod-travel-portal --> flights.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 5
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] viaggi.prod-travel-portal --> insurances.prod-travel-agency"
else
  echo "[DENY] viaggi.prod-travel-portal --> insurances.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-portal | grep viaggi | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n prod-travel-portal -c control exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 5
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] viaggi.prod-travel-portal --> hotels.prod-travel-agency"
else
  echo "[DENY] viaggi.prod-travel-portal --> hotels.prod-travel-agency"
fi


echo
echo "Authorization prod-travel-agency --> prod-travel-agency"
echo "-------------------------------------------------------------------"

podname=$(oc get pods -n prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
travels=$(oc -n prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET travels.prod-travel-agency.svc.cluster.local:8000/travels/Tallinn)
#echo travels
sleep 5
if [[ travels -eq 200 ]]
then
  echo "[ALLOW] travels.prod-travel-portal --> discounts.prod-travel-agency"
else
  echo "[DENY] travels.prod-travel-portal --> discounts.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
cars=$(oc -n prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET cars.prod-travel-agency.svc.cluster.local:8000/cars/Tallinn)
#echo cars
sleep 5
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] travels.prod-travel-portal --> cars.prod-travel-agency"
else
  echo "[DENY] travels.prod-travel-portal --> cars.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
flights=$(oc -n prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET flights.prod-travel-agency.svc.cluster.local:8000/flights/Tallinn)
#echo flights
sleep 5
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] travels.prod-travel-portal --> flights.prod-travel-agency"
else
  echo "[DENY] travels.prod-travel-portal --> flights.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
insurances=$(oc -n prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET insurances.prod-travel-agency.svc.cluster.local:8000/insurances/Tallinn)
#echo insurances
sleep 5
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] travels.prod-travel-portal --> insurances.prod-travel-agency"
else
  echo "[DENY] travels.prod-travel-portal --> insurances.prod-travel-agency"
fi

podname=$(oc get pods -n prod-travel-agency | grep travels | awk '{print $1}')
#echo $podname
sleep 3
hotels=$(oc -n prod-travel-agency -c travels exec $podname -- curl -s -o /dev/null -w "%{http_code}" -X GET hotels.prod-travel-agency.svc.cluster.local:8000/hotels/Tallinn)
#echo $hotels
sleep 5
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] travels.prod-travel-portal --> hotels.prod-travel-agency"
else
  echo "[DENY] travels.prod-travel-portal --> hotels.prod-travel-agency"
fi