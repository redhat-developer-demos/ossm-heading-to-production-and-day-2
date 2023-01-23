#!/bin/bash

echo
echo "---------------------------------------------"
echo "Mesh Dev Farid (Travel Services Domain) Reset"
echo "---------------------------------------------"
./login-as.sh farid
oc delete smm default -n prod-travel-agency
oc delete -f travel-agency/travel_agency.yaml -n prod-travel-agency

echo
echo "------------------------------------------------"
echo "Mesh Dev Cristina (Travel Portal Domain) Reset"
echo "------------------------------------------------"
./login-as.sh cristina
oc delete smm default -n prod-travel-portal
oc delete smm default -n prod-travel-control
oc delete -f travel-portal/travel_portal.yaml -n prod-travel-portal
oc delete -f travel-portal/travel_control.yaml -n prod-travel-control

echo
echo "----------------------------------------"
echo "Mesh Operator emma SMCP Reset & secret with certs"
echo "----------------------------------------"
#./login-as.sh emma
#oc delete jaeger jaeger-small-production -n prod-istio-system
#oc delete smcp production -n prod-istio-system

echo
echo "----------------------------------------"
echo "Cluster Admin Reset"
echo "----------------------------------------"
#./login-as.sh phillip
#oc delete project prod-travel-control
#oc delete project prod-travel-portal
#oc delete project prod-travel-agency
#oc delete project prod-istio-system
