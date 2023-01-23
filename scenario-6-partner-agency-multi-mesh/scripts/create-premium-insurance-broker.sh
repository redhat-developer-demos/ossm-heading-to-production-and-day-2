#!/bin/bash

NAMESPACE=$1
SM_CP_NS=$2
DOMAIN_NAME=$3 #eg. apps.ocp4.rhlab.de
PREFIX=$4

cd scripts

echo '---------------------------------------------------------------------------'
echo 'Partner Namespace                          : '$NAMESPACE
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'CLUSTER DOMAIN NAME                        : '$DOMAIN_NAME
echo 'PREFIX                                     : '$PREFIX
echo '---------------------------------------------------------------------------'

sleep 5
echo
echo "---------------------------------------------------"
echo "Partner Insurance Service ServiceMeshControlPlane"
echo "---------------------------------------------------"
echo
oc new-project $SM_CP_NS
echo
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $PREFIX
  namespace: $SM_CP_NS
spec:
  security:
    controlPlane:
      mtls: true
    dataPlane:
      mtls: true
  tracing:
    type: Jaeger
    sampling: 10000
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
    jaeger:
      install:
        storage:
          type: Memory
    kiali:
      enabled: true
    prometheus:
      enabled: true
  gateways:
    openshiftRoute:
      enabled: false
  telemetry:
    type: Istiod
  version: v2.2"
echo
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $PREFIX
  namespace: $SM_CP_NS
spec:
  security:
    controlPlane:
      mtls: true
    dataPlane:
      mtls: true
  tracing:
    type: Jaeger
    sampling: 10000
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
    jaeger:
      install:
        storage:
          type: Memory
    kiali:
      enabled: true
    prometheus:
      enabled: true
  gateways:
    openshiftRoute:
      enabled: false
  telemetry:
    type: Istiod
  version: v2.2" |oc apply -f -

echo "oc wait --for condition=Ready -n $SM_CP_NS smcp/$PREFIX --timeout=300s"
echo
echo
oc wait --for condition=Ready -n $SM_CP_NS smcp/$PREFIX --timeout=300s
echo
echo
oc -n $SM_CP_NS  get smcp/$PREFIX

echo
echo
oc new-project $NAMESPACE
echo
../../common-scripts/create-membership.sh $SM_CP_NS $PREFIX $NAMESPACE
echo
echo
./deploy-partner-travel-insurance-domain.sh $NAMESPACE $SM_CP_NS
echo
echo
./enable-premium-insurance-traffic.sh $NAMESPACE $SM_CP_NS $DOMAIN_NAME $PREFIX
