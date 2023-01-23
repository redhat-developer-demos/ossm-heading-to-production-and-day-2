#!/bin/bash

https_mutual_route=$1
place=$2

echo
echo "Flights to:   [$place]"
echo "----------------------------"
echo "curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/flights/$place"
curl -v -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/flights/$place |jq
sleep 3

echo
echo "Hotels at:   [$place]"
echo "----------------------------"
echo "curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/hotels/$place"
curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/hotels/$place |jq
sleep 3

echo
echo "Cars at:   [$place]"
echo "----------------------------"
echo "curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/cars/$place"
curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/cars/$place |jq
sleep 3

echo
echo "Insurance for:   [$place]"
echo "----------------------------"
echo "curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/insurances/$place"
curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/insurances/$place |jq
sleep 3

echo
echo "Travels for:   [$place]"
echo "----------------------------"
echo "curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/travels/$place"
curl -s -X GET --cacert ca-root.crt --key curl-client.key --cert curl-client.crt  $https_mutual_route/travels/$place |jq
sleep 5