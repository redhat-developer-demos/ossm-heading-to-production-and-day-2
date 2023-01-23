#!/bin/bash

SM_CP_NS=$1
PREFIX=$2
TOKEN=$3

GATEWAY_URL=$(oc get route $PREFIX -o jsonpath='{.spec.host}' -n $SM_CP_NS)
echo GATEWAY_URL:  $GATEWAY_URL
echo
sleep 3

for i in {1..10}
do

curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Tallinn |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Tallinn |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Tallinn |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Tallinn |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Tallinn |jq

curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Brussels |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Brussels |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Brussels |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Brussels |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Brussels |jq

curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/cars/Warsaw |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/travels/Warsaw |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/flights/Warsaw |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/insurances/Warsaw |jq
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt -H "Authorization: Bearer $TOKEN" https://$GATEWAY_URL/hotels/Warsaw |jq

done