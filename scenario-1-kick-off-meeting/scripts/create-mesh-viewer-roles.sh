#!/bin/bash

USERNAME=$1
#SM_CP_NAMESPACE=$2
NAMESPACES=$2


echo
echo "#######################################################################################################################################"
echo "  USAGE: "
#echo "          ./create-mesh-viewer-roles.sh <USERNAME> <SERVICEMESH_CP_NAMESPACE> <COLON_DELIMITED_DATAPLANE_NAMESPACES>"
#echo "	   eg.  ./create-mesh-viewer-roles.sh nick istio-system travel-agency:travel-control,travel-portal"
echo "          ./create-mesh-viewer-roles.sh <USERNAME> <COLON_DELIMITED_DATAPLANE_NAMESPACES>:<SERVICEMESH_CP_NAMESPACE> "
echo "	   eg.  ./create-mesh-viewer-roles.sh nick travel-agency:travel-control,travel-portal:istio-system"
echo ""
echo " WARNING: Multiple Namespaces [$NAMESPACES] must be seperated by colon `:`"
echo "#######################################################################################################################################"
echo
sleep 7
echo
echo '---------------------------------------------------------------------------'
echo 'USERNAME        : '$USERNAME
#echo 'SM_CP_NAMESPACE : '$SM_CP_NAMESPACE
echo 'NAMESPACES      : '$NAMESPACES
echo '---------------------------------------------------------------------------'


# This role does not allow jaeger/prometheus/grafana view for the viewer
#echo "oc adm policy add-role-to-user view $USERNAME -n $ISTIO_NAMESPACE"
#oc adm policy add-role-to-user view $USERNAME -n $ISTIO_NAMESPACE 


set -f                      # avoid globbing (expansion of *).
array=(${NAMESPACES//:/ })
for i in "${!array[@]}"
do
    echo "$i=> oc adm policy add-role-to-user servicemesh-app-viewer $USERNAME -n ${array[i]}"
    oc adm policy add-role-to-user servicemesh-app-viewer $USERNAME -n ${array[i]}
done




