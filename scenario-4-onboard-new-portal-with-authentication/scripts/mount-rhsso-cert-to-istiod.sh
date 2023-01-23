#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2
CLUSTERNAME=$3
BASEDOMAIN=$4

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo 'OCP Cluster Name                           : '$CLUSTERNAME
echo 'OCP Cluster BaseDomain Name                : '$BASEDOMAIN
echo '---------------------------------------------------------------------------'

echo
echo
sleep 7
echo "Retrieve the CA certificate from secret in openshift-ingress-operator project"
echo "-----------------------------------------------------------------------------"
echo "oc extract secret/router-ca -n openshift-ingress-operator --to=/tmp/"
sleep 5
oc extract secret/router-ca -n openshift-ingress-operator --to=/tmp/
sleep 3
echo

echo "Create a secret from this CA certificate in $SM_CP_NS project"
echo "-----------------------------------------------------------------------------"
oc -n $SM_CP_NS delete secret/openshift-wildcard
echo "oc -n $SM_CP_NS create secret generic openshift-wildcard --from-file=extra.pem=/tmp/tls.crt"
sleep 5
oc -n $SM_CP_NS create secret generic openshift-wildcard --from-file=extra.pem=/tmp/tls.crt
sleep 3
echo

echo "Mount the CA secret at the specific location '/cacerts/extra.pem' in istiod pod"
echo "-----------------------------------------------------------------------------"
oc set volume -n $SM_CP_NS deployment/istiod-$SM_TENANT_NAME --remove --name=extracacerts --containers=discovery
echo
echo
sleep 15
echo "oc set volumes -n $SM_CP_NS deployment/istiod-$SM_TENANT_NAME --add  --name=extracacerts  --mount-path=/cacerts  --secret-name=openshift-wildcard  --containers=discovery"
sleep 5
oc set volumes -n $SM_CP_NS deployment/istiod-$SM_TENANT_NAME --add  --name=extracacerts  --mount-path=/cacerts  --secret-name=openshift-wildcard  --containers=discovery
sleep 13
echo

echo "Verification of the Procedure"
echo "-----------------------------------------------------------------------------"
echo "podname=oc get pods -n $SM_CP_NS | grep istiod-$SM_TENANT_NAME | awk '{print \$1}'"
podname=$(oc get pods -n $SM_CP_NS | grep istiod-$SM_TENANT_NAME | awk '{print $1}')
echo
echo "podname=$podname"
sleep 5

# RSH to istiod pod
#echo "oc -n $SM_CP_NS rsh $podname"
#oc -n $SM_CP_NS rsh $podname
echo
echo
echo "Check connection to RHSSO without the CA"
#[pod] sh-4.4$ curl -I https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/
echo "oc -n $SM_CP_NS exec $podname -- curl -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/"
sleep 7
oc -n $SM_CP_NS exec $podname -- curl -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/
#curl: (60) SSL certificate problem: self signed certificate in certificate chain
echo
echo
sleep 7

echo "Check connection to RHSSO with the CA"
#[pod] sh-4.4$ curl --cacert /cacerts/extra.pem -I https://keycloak-rhsso.apps.<CLUSTERNAME>.<BASEDOMAIN>/auth/
echo "oc -n $SM_CP_NS exec $podname -- curl --cacert /cacerts/extra.pem -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/"
sleep 7
oc -n $SM_CP_NS exec $podname -- curl --cacert /cacerts/extra.pem -I https://keycloak-rhsso.apps.$CLUSTERNAME.$BASEDOMAIN/auth/
#HTTP/1.1 200 OK
echo
echo





