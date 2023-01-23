#!/bin/bash

echo
echo "---------------------------------------------"
echo "Mesh Dev Farid (Travel Services Domain) Reset"
echo "---------------------------------------------"
./login-as.sh farid
oc delete smm default -n dev-travel-agency
oc delete -f ../travel-agency/travel_agency.yaml -n dev-travel-agency

echo
echo "------------------------------------------------"
echo "Mesh Dev Cristina (Travel Portal Domain) Reset"
echo "------------------------------------------------"
./login-as.sh cristina
oc delete smm default -n dev-travel-portal
oc delete smm default -n dev-travel-control
oc delete -f ../travel-portal/travel_portal.yaml -n dev-travel-portal
oc delete -f ../travel-portal/travel_control.yaml -n dev-travel-control

echo
echo "----------------------------------------"
echo "Mesh Operator emma SMCP Reset"
echo "----------------------------------------"
./login-as.sh emma
oc delete smcp dev-basic -n dev-istio-system

echo
echo "----------------------------------------"
echo "Cluster Admin Reset"
echo "----------------------------------------"
#./login-as.sh phillip
#oc delete project dev-travel-control
#oc delete project dev-travel-portal
#oc delete project dev-travel-agency
#oc delete project dev-istio-system
