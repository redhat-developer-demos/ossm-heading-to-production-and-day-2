#!/bin/bash

SM_CP_NS=$1 #eg. prod-istio-system
CLUSTERNAME=$2 #eg. ocp4
BASEDOMAIN=$3 #eg example.com
CERTS_LOCATION=../scenario-4-onboard-new-portal-with-authentication

echo "####################################################################"
echo "#                                                                  #"
echo "#           VERIFY GTO FINE GRAINED AUTHZ                          #"
echo "#               DENY unless /flights/* or /insurances/*            #"
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

if [[ $travels -eq 200 ]]
then
  echo "[ALLOW] GTO --> /travels"
else
  echo "[DENY] GTO --> /travels"
fi
if [[ cars -eq 200 ]]
then
  echo "[ALLOW] GTO --> /cars"
else
  echo "[DENY] GTO --> /cars"
fi
if [[ flights -eq 200 ]]
then
  echo "[ALLOW] GTO --> /flights"
else
  echo "[DENY] GTO --> /flights"
fi
if [[ insurances -eq 200 ]]
then
  echo "[ALLOW] GTO --> /insurances"
else
  echo "[DENY] GTO --> /insurances"
fi
if [[ hotels -eq 200 ]]
then
  echo "[ALLOW] GTO --> /hotels"
else
  echo "[DENY] GTO --> /hotels"
fi