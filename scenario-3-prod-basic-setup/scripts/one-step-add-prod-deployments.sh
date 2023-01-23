#!/bin/bash


DOMAIN_NAME=$1

echo
echo
echo "#################################################################"
echo "#                                                               #"
echo "# Deploy Travel Domain Services                                 #"
echo "#                                                               #"
echo "#################################################################"
echo
../login-as.sh farid
../../common-scripts/create-membership.sh prod-istio-system production prod-travel-agency
sleep 5
./deploy-travel-services-domain.sh prod prod-istio-system

sleep 7

echo
echo
echo "#################################################################"
echo "#                                                               #"
echo "# Deploy Portal Domain Services                                 #"
echo "#                                                               #"
echo "#################################################################"
echo
../login-as.sh cristina
../../common-scripts/create-membership.sh prod-istio-system production prod-travel-control
../../common-scripts/create-membership.sh prod-istio-system production prod-travel-portal
sleep 5
./deploy-travel-portal-domain.sh prod prod-istio-system $DOMAIN_NAME