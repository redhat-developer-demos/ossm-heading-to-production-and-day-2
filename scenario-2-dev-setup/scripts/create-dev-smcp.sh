#!/bin/bash

SM_CP_NS=$1
SM_TENANT_NAME=$2

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Control Plane Tenant Name      : '$SM_TENANT_NAME
echo '---------------------------------------------------------------------------'

#echo "Create namespace $SM_CP_NS"
#echo "oc create ns  $SM_CP_N"   
#oc create ns  $SM_CP_N

echo "############# Creating SM Tenant [$SM_TENANT_NAME] in Namespace [$SM_CP_NS ] #############"
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $SM_TENANT_NAME
spec:
  security:
    dataPlane:
      automtls: true
      mtls: true
  tracing:
    sampling: 10000
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: REGISTRY_ONLY
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
  version: v2.2
  telemetry:
    type: Istiod"
    
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $SM_TENANT_NAME
spec:
  security:
    controlPlane:  
      mtls: true
    dataPlane:
      automtls: true
      mtls: true
  tracing:
    sampling: 10000
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: REGISTRY_ONLY
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
  version: v2.2
  telemetry:
    type: Istiod"| oc apply -n $SM_CP_NS -f -

sleep 3
echo
echo
echo "oc wait --for condition=Ready -n $SM_CP_NS smcp/$SM_TENANT_NAME --timeout=300s"
echo
echo
oc wait --for condition=Ready -n $SM_CP_NS smcp/$SM_TENANT_NAME --timeout=300s
echo
echo
