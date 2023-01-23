#!/bin/bash

FED_1_SMCP_NAMESPACE=$1 #prod-istio-system
FED_1_SMCP_NAME=$2 #production
FED_2_SMCP_NAMESPACE=$3 #partner-istio-system
FED_2_SMCP_NAME=$4 #partner
NAMESPACE=$5 #premium-broker

echo
echo
echo
echo
echo 'Starting Federation Setup ...'
echo
sleep 2
echo
echo '---------------------------------------------------------------------------'
echo 'Federated ServiceMesh Control Plane 1 Namespace        : '$FED_1_SMCP_NAMESPACE
echo 'Federated ServiceMesh Control Plane 1 Tenant Name      : '$FED_1_SMCP_NAME
echo 'Federated ServiceMesh Control Plane 2 Namespace        : '$FED_2_SMCP_NAMESPACE
echo 'Federated ServiceMesh Control Plane 2 Tenant Name      : '$FED_2_SMCP_NAME
echo 'Partner Dataplane Namespace                            : '$NAMESPACE
echo '---------------------------------------------------------------------------'
echo
echo

echo '###########################################################################'
echo '#                                                                         #'
echo '#   STAGE 1 - SMCP Preperations for Federation                            #'
echo '#                                                                         #'
echo '###########################################################################'
echo
sleep 4
echo "---------------------- Step 1-a Update SMCP/$FED_1_SMCP_NAME in Namespace [$FED_1_SMCP_NAMESPACE] with Federation Gateways   ----------------------"
sleep 7
echo

echo "LOGIN CLUSTER 1 [$FED_1_SMCP_NAME] as $(oc whoami)"
echo
sleep 5


echo "Current SMCP/$FED_1_SMCP_NAME
-------------------------------------
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  namespace: prod-istio-system
  name: production
spec:
  security:
    certificateAuthority:
      istiod:
        privateKey:
          rootCADir: /etc/cacerts
        type: PrivateKey
      type: Istiod
    dataPlane:
      automtls: true
      mtls: true
  tracing:
    sampling: 500
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 128Mi
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: REGISTRY_ONLY
  gateways:
    egress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    enabled: true
    ingress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    additionalIngress:
      gto-external-ingressgateway:
        enabled: true
        runtime:
          deployment:
            autoScaling:
              enabled: false
        service:
          metadata:
            labels:
              app: gto-external-ingressgateway
          selector:
            app: gto-external-ingressgateway
    openshiftRoute:
      enabled: false
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
      install:
        config:
          env: {}
          envSecrets: {}
        persistence:
          accessMode: ReadWriteOnce
          capacity:
            requests:
              storage: 5Gi
          enabled: true
        service:
          ingress:
            contextPath: /grafana
            tls:
              termination: reencrypt
    jaeger:
      install:
        ingress:
          enabled: true
        storage:
          type: Elasticsearch
      name: jaeger-small-production
    kiali:
      enabled: true
    prometheus:
      enabled: true
  runtime:
    components:
      pilot:
        deployment:
          replicas: 2
        pod:
          affinity: {}
        container:
          resources:
          limits: {}
          requirements: {}
      grafana:
        deployment: {}
        pod: {}
      kiali:
        deployment: {}
        pod: {}
  version: v2.2
  telemetry:
    type: Istiod"

echo
echo "----- Updated for federation SMCP/$FED_1_SMCP_NAME ----"
echo
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  security:
    certificateAuthority:
      istiod:
        privateKey:
          rootCADir: /etc/cacerts
        type: PrivateKey
      type: Istiod
    dataPlane:
      automtls: true
      mtls: true
    trust:
      domain: $FED_1_SMCP_NAME.local
  tracing:
    sampling: 500
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 128Mi
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: REGISTRY_ONLY
  gateways:
    egress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    enabled: true
    ingress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    additionalEgress:
      partner-mesh-egress:
        enabled: true
        requestedNetworkView:
        - partner-network
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/egress-for: partner-mesh-egress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      partner-mesh-ingress:
        enabled: true
        routerMode: sni-dnat
        service:
          type: ClusterIP
          metadata:
            labels:
              federation.maistra.io/ingress-for: partner-mesh-ingress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery
      gto-external-ingressgateway:
        enabled: true
        runtime:
          deployment:
            autoScaling:
              enabled: false
        service:
          metadata:
            labels:
              app: gto-external-ingressgateway
          selector:
            app: gto-external-ingressgateway
    openshiftRoute:
      enabled: false
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
      install:
        config:
          env: {}
          envSecrets: {}
        persistence:
          accessMode: ReadWriteOnce
          capacity:
            requests:
              storage: 5Gi
          enabled: true
        service:
          ingress:
            contextPath: /grafana
            tls:
              termination: reencrypt
    jaeger:
      install:
        ingress:
          enabled: true
        storage:
          type: Elasticsearch
      name: jaeger-small-production
    kiali:
      enabled: true
    prometheus:
      enabled: true
  runtime:
    components:
      pilot:
        deployment:
          replicas: 2
        pod:
          affinity: {}
        container:
          resources:
          limits: {}
          requirements: {}
      grafana:
        deployment: {}
        pod: {}
      kiali:
        deployment: {}
        pod: {}
  version: v2.2
  telemetry:
    type: Istiod"

echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  security:
    certificateAuthority:
      istiod:
        privateKey:
          rootCADir: /etc/cacerts
        type: PrivateKey
      type: Istiod
    dataPlane:
      automtls: true
      mtls: true
    trust:
      domain: $FED_1_SMCP_NAME.local
  tracing:
    sampling: 500
    type: Jaeger
  general:
    logging:
      logAsJSON: true
  profiles:
    - default
  proxy:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 128Mi
    accessLogging:
      file:
        name: /dev/stdout
    networking:
      trafficControl:
        inbound: {}
        outbound:
          policy: REGISTRY_ONLY
  gateways:
    egress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    enabled: true
    ingress:
      enabled: true
      runtime:
        deployment:
          autoScaling:
            enabled: true
            maxReplicas: 2
            minReplicas: 2
        pod: {}
      service: {}
    additionalEgress:
      partner-mesh-egress:
        enabled: true
        requestedNetworkView:
        - partner-network
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/egress-for: partner-mesh-egress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      partner-mesh-ingress:
        enabled: true
        routerMode: sni-dnat
        service:
          type: ClusterIP
          metadata:
            labels:
              federation.maistra.io/ingress-for: partner-mesh-ingress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery
      gto-external-ingressgateway:
        enabled: true
        runtime:
          deployment:
            autoScaling:
              enabled: false
        service:
          metadata:
            labels:
              app: gto-external-ingressgateway
          selector:
            app: gto-external-ingressgateway
    openshiftRoute:
      enabled: false
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
      install:
        config:
          env: {}
          envSecrets: {}
        persistence:
          accessMode: ReadWriteOnce
          capacity:
            requests:
              storage: 5Gi
          enabled: true
        service:
          ingress:
            contextPath: /grafana
            tls:
              termination: reencrypt
    jaeger:
      install:
        ingress:
          enabled: true
        storage:
          type: Elasticsearch
      name: jaeger-small-production
    kiali:
      enabled: true
    prometheus:
      enabled: true
  runtime:
    components:
      pilot:
        deployment:
          replicas: 2
        pod:
          affinity: {}
        container:
          resources:
          limits: {}
          requirements: {}
      grafana:
        deployment: {}
        pod: {}
      kiali:
        deployment: {}
        pod: {}
  version: v2.2
  telemetry:
    type: Istiod"|oc apply -f -

echo
echo
echo "oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smcp/$FED_1_SMCP_NAME --timeout 300s"
sleep 15
echo
oc wait --for condition=Ready -n $FED_1_SMCP_NAMESPACE smcp/$FED_1_SMCP_NAME --timeout=300s
echo
echo
oc -n $FED_1_SMCP_NAMESPACE  get smcp/$FED_1_SMCP_NAME

echo
sleep 4
echo "---------------------- Step 1-b Update SMCP/$FED_2_SMCP_NAME in Namespace [$FED_2_SMCP_NAMESPACE] with Federation Gateways   ----------------------"
sleep 7
echo

echo "LOGIN CLUSTER 1 [$FED_2_SMCP_NAME] as $(oc whoami)"

echo
sleep 5

echo
echo "Current SMCP/$FED_2_SMCP_NAME
-------------------------------------
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_2_SMCP_NAME
  namespace: ${FED_2_SMCP_NAMESPACE}
spec:
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
  policy:
    type: Istiod
  profiles:
    - default
  security:
    controlPlane:
      mtls: true
    dataPlane:
      mtls: true
  telemetry:
    type: Istiod
  tracing:
    sampling: 10000
    type: Jaeger
  version: v2.2"


echo
echo "----- Updated for federation SMCP/$FED_2_SMCP_NAME ----"
echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_2_SMCP_NAME
  namespace: ${FED_2_SMCP_NAMESPACE}
spec:
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
    additionalEgress:
      production-mesh-egress:
        enabled: true
        requestedNetworkView:
        - production-network
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/egress-for: production-mesh-egress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      production-mesh-ingress:
        enabled: true
        routerMode: sni-dnat
        service:
          type: ClusterIP
          metadata:
            labels:
              federation.maistra.io/ingress-for: production-mesh-ingress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery
    openshiftRoute:
      enabled: false
  security:
    controlPlane:
      mtls: true
    dataPlane:
      mtls: true
    trust:
      domain: $FED_2_SMCP_NAME.local
  profiles:
    - default
  telemetry:
    type: Istiod
  tracing:
    sampling: 10000
    type: Jaeger
  policy:
    type: Istiod
  version: v2.2"

echo "apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: $FED_2_SMCP_NAME
  namespace: ${FED_2_SMCP_NAMESPACE}
spec:
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
    additionalEgress:
      production-mesh-egress:
        enabled: true
        requestedNetworkView:
        - production-network
        routerMode: sni-dnat
        service:
          metadata:
            labels:
              federation.maistra.io/egress-for: production-mesh-egress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: http-discovery
    additionalIngress:
      production-mesh-ingress:
        enabled: true
        routerMode: sni-dnat
        service:
          type: ClusterIP
          metadata:
            labels:
              federation.maistra.io/ingress-for: production-mesh-ingress
          ports:
          - port: 15443
            name: tls
          - port: 8188
            name: https-discovery
    openshiftRoute:
      enabled: false
  security:
    controlPlane:
      mtls: true
    dataPlane:
      mtls: true
    trust:
      domain: $FED_2_SMCP_NAME.local
  profiles:
    - default
  telemetry:
    type: Istiod
  tracing:
    sampling: 10000
    type: Jaeger
  policy:
    type: Istiod
  version: v2.2" |oc apply -f -

echo
echo
echo "oc wait --for condition=Ready -n $FED_2_SMCP_NAMESPACE smcp/$FED_2_SMCP_NAME --timeout 300s"
sleep 15
echo
oc wait --for condition=Ready -n $FED_2_SMCP_NAMESPACE smcp/$FED_2_SMCP_NAME --timeout=300s
echo
echo
oc -n $FED_2_SMCP_NAMESPACE  get smcp/$FED_2_SMCP_NAME

echo
echo
echo '###########################################################################'
echo '#                                                                         #'
echo '#   STAGE 2 - Create PEERING between meshes                               #'
echo '#                                                                         #'
echo '###########################################################################'
echo
sleep 5

echo '---------------------- Step 2 - Share mesh root certs to validate each other client certs  ----------------------'

echo '==========================='
echo "FROM $FED_1_SMCP_NAME MESH"
echo '==========================='
sleep 5
echo "a. GET ROOT CA CERT FROM $FED_1_SMCP_NAME MESH:					oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_1_SMCP_NAMESPACE > production-mesh-cert.pem"
echo
sleep 5
oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_1_SMCP_NAMESPACE > production-mesh-cert.pem
echo
sleep 5
echo
echo '==============================='
echo "SHARE TO $FED_2_SMCP_NAME MESH"
echo '==============================='
sleep 5
echo
echo "b. CREATE IN $FED_2_SMCP_NAMESPACE with $FED_1_SMCP_NAME MESH CERT a configmap:		oc create configmap production-ca-root-cert --from-file=root-cert.pem=production-mesh-cert.pem -n $FED_2_SMCP_NAMESPACE"
echo
sleep 5
oc delete configmap production-ca-root-cert -n $FED_2_SMCP_NAMESPACE
oc create configmap production-ca-root-cert --from-file=root-cert.pem=production-mesh-cert.pem -n $FED_2_SMCP_NAMESPACE

echo '==========================='
echo "FROM $FED_2_SMCP_NAME MESH"
echo '==========================='
sleep 5
echo "c. GET ROOT CA CERT FROM $FED_2_SMCP_NAME MESH:					oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_2_SMCP_NAMESPACE > partner-mesh-cert.pem"
oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_2_SMCP_NAMESPACE > partner-mesh-cert.pem
echo
sleep 5

echo
echo '==============================='
echo "SHARE TO $FED_1_SMCP_NAME MESH"
echo '==============================='
echo "d. CREATE IN $FED_1_SMCP_NAMESPACE with $FED_2_SMCP_NAME MESH CERT a configmap:		oc create configmap partner-ca-root-cert --from-file=root-cert.pem=partner-mesh-cert.pem -n $FED_1_SMCP_NAMESPACE"
oc delete configmap partner-ca-root-cert -n $FED_1_SMCP_NAMESPACE
oc create configmap partner-ca-root-cert --from-file=root-cert.pem=partner-mesh-cert.pem -n $FED_1_SMCP_NAMESPACE
echo
sleep 15
echo

echo
echo
echo '---------------------- Step 3a - Setup Service Mesh Peering & Service Imports (PRODUCTION -> PARTNER)  ----------------------'
sleep 7
echo
echo "kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - production-mesh-ingress.$FED_2_SMCP_NAMESPACE.svc.cluster.local
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: partner-mesh-ingress
    egress:
      name: partner-mesh-egress
  security:
    trustDomain: $FED_2_SMCP_NAME.local
    clientID: $FED_2_SMCP_NAME.local/ns/$FED_2_SMCP_NAMESPACE/sa/production-mesh-egress-service-account
    certificateChain:
      kind: ConfigMap
      name: partner-ca-root-cert"

echo "kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - production-mesh-ingress.$FED_2_SMCP_NAMESPACE.svc.cluster.local
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: partner-mesh-ingress
    egress:
      name: partner-mesh-egress
  security:
    trustDomain: $FED_2_SMCP_NAME.local
    clientID: $FED_2_SMCP_NAME.local/ns/$FED_2_SMCP_NAMESPACE/sa/production-mesh-egress-service-account
    certificateChain:
      kind: ConfigMap
      name: partner-ca-root-cert" |oc apply -f -
sleep 7
echo
# If you import services with importAsLocal: true,
# the domain suffix will be svc.cluster.local, like your normal local services.
# So, if you already have a local service with this name, the remote endpoint will be
# added to this service’s endpoints and you load balance across your local and imported services.
echo "
kind: ImportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  importRules:
  - importAsLocal: false
    nameSelector:
      name: insurances
      namespace: $NAMESPACE
    type: NameSelector"
#  importRules:
#  - type: NameSelector
#    nameSelector:
#      importAsLocal: false
#      namespace: $NAMESPACE
#      name: insurances
echo "
kind: ImportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_2_SMCP_NAME
  namespace: $FED_1_SMCP_NAMESPACE
spec:
  importRules:
  - importAsLocal: false
    nameSelector:
      name: insurances
      namespace: $NAMESPACE
    type: NameSelector" |oc apply -f -
#  importRules:
#  - type: NameSelector
#    nameSelector:
#      importAsLocal: false
#      namespace: $NAMESPACE
#      name: insurances
sleep 15
echo
echo

echo '---------------------- Step 3b - Setup Service Mesh Peering & Service Exports (PARTNER -> PRODUCTION)  ----------------------'
sleep 7
echo
echo
echo "kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - partner-mesh-ingress.$FED_1_SMCP_NAMESPACE.svc.cluster.local
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: production-mesh-ingress
    egress:
      name: production-mesh-egress
  security:
    trustDomain: $FED_1_SMCP_NAME.local
    clientID: $FED_1_SMCP_NAME.local/ns/$FED_1_SMCP_NAMESPACE/sa/partner-mesh-egress-service-account
    certificateChain:
      kind: ConfigMap
      name: production-ca-root-cert"

echo "kind: ServiceMeshPeer
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  remote:
    addresses:
    - partner-mesh-ingress.$FED_1_SMCP_NAMESPACE.svc.cluster.local
    discoveryPort: 8188
    servicePort: 15443
  gateways:
    ingress:
      name: production-mesh-ingress
    egress:
      name: production-mesh-egress
  security:
    trustDomain: $FED_1_SMCP_NAME.local
    clientID: $FED_1_SMCP_NAME.local/ns/$FED_1_SMCP_NAMESPACE/sa/partner-mesh-egress-service-account
    certificateChain:
      kind: ConfigMap
      name: production-ca-root-cert" |oc apply -f -
sleep 7
echo
#echo "
#kind: ExportedServiceSet
#apiVersion: federation.maistra.io/v1
#metadata:
#  name: $FED_1_SMCP_NAME
#  namespace: $FED_2_SMCP_NAMESPACE
#spec:
#  exportRules:
#  - type: LabelSelector
#    labelSelector:
#      namespace: $NAMESPACE
#      selector:
#        matchLabels:
#          app: insurances
#      alias:
#        namespace: prod-travel-agency"
#echo "
#kind: ExportedServiceSet
#apiVersion: federation.maistra.io/v1
#metadata:
#  name: $FED_1_SMCP_NAME
#  namespace: $FED_2_SMCP_NAMESPACE
#spec:
#  exportRules:
#  - type: LabelSelector
#    labelSelector:
#      namespace: $NAMESPACE
#      selector:
#        matchLabels:
#          app: insurances
#      alias:
#        namespace: prod-travel-agency" |oc apply -f -

echo "kind: ExportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  exportRules:
  - type: NameSelector
    nameSelector:
      namespace: $NAMESPACE
      name: insurances"

echo "kind: ExportedServiceSet
apiVersion: federation.maistra.io/v1
metadata:
  name: $FED_1_SMCP_NAME
  namespace: $FED_2_SMCP_NAMESPACE
spec:
  exportRules:
  - type: NameSelector
    nameSelector:
      namespace: $NAMESPACE
      name: insurances" |oc apply -f -
sleep 10
echo
echo

echo '---------------------- Step 3c - Verify Service Mesh Peering Connection (PRODUCTION -> PARTNER)  ----------------------'
sleep 7
echo
echo "------------------------------------ CHECK ServiceMeshPeering (PRODUCTION -> PARTNER) STATUS ------------------------------------"
echo 'NOTE: Check if status \"connected: true\" 305 times with 1 sec delay as 5 mins peering synced'
echo "oc get servicemeshpeer $FED_2_SMCP_NAME -o jsonpath='{.status.discoveryStatus.active[0].watch.connected}' -n $FED_1_SMCP_NAMESPACE"
echo
espod="False"
while [ "$espod" != "true" ]; do
  sleep 5
  espod=$(oc get servicemeshpeer $FED_2_SMCP_NAME -o jsonpath='{.status.discoveryStatus.active[0].watch.connected}{"\n"}' -n $FED_1_SMCP_NAMESPACE)
  echo "ServiceMeshPeer PRODUCTION -> PARTNER Connected => "$espod
done
sleep 1
echo
sleep 12
echo
echo
echo '---------------------- Step 3d - Verify Service Mesh Peering Connection (PARTNER -> PRODUCTION)  ----------------------'
sleep 7
echo
echo "------------------------------------ CHECK ServiceMeshPeering (PARTNER -> PRODUCTION) STATUS ------------------------------------"
echo 'NOTE: Check if status \"connected: true\" 305 times with 1 sec delay as 5 mins peering synced'
echo "oc get servicemeshpeer $FED_1_SMCP_NAME -o jsonpath='{.status.discoveryStatus.active[0].remotes[0].connected}' -n $FED_2_SMCP_NAMESPACE"
espod="False"
while [ "$espod" != "true" ]; do
  sleep 5
  espod=$(oc get servicemeshpeer $FED_1_SMCP_NAME -o jsonpath='{.status.discoveryStatus.active[0].remotes[0].connected}{"\n"}' -n $FED_2_SMCP_NAMESPACE)
  echo "ServiceMeshPeer PARTNER -> PRODUCTION Connected => "$espod
done
echo
sleep 10
echo
echo
echo '---------------------- Step 4 - Apply Routing Rules  ----------------------'

echo "apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-insurances-versions
  namespace: prod-travel-agency
spec:
  host: insurances
  subsets:
  - name: v1
    labels:
      version: v1
  - name: premium
    labels:
      version: premium"

echo "apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-insurances-versions
  namespace: prod-travel-agency
spec:
  host: insurances
  subsets:
  - name: v1
    labels:
      version: v1
  - name: premium
    labels:
      version: premium"|oc apply -f -

echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
 name: vs-insurances-split
 namespace: prod-travel-agency
spec:
 hosts:
   - insurances.prod-travel-agency.svc.cluster.local
 http:
    - match:
        - uri:
            exact: /insurances/London
        - uri:
            exact: /insurances/Rome
        - uri:
            exact: /insurances/Paris
        - uri:
            exact: /insurances/Berlin
        - uri:
            exact: /insurances/Munich
        - uri:
            exact: /insurances/Dublin
      route:
        - destination:
            host: insurances.$NAMESPACE.svc.$FED_2_SMCP_NAME-imports.local
          weight: 100
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: insurances.prod-travel-agency.svc.cluster.local
            subset: v1
          weight: 100"

echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
 name: vs-insurances-split
 namespace: prod-travel-agency
spec:
 hosts:
   - insurances.prod-travel-agency.svc.cluster.local
 http:
    - match:
        - uri:
            exact: /insurances/London
        - uri:
            exact: /insurances/Rome
        - uri:
            exact: /insurances/Paris
        - uri:
            exact: /insurances/Berlin
        - uri:
            exact: /insurances/Munich
        - uri:
            exact: /insurances/Dublin
      route:
        - destination:
            host: insurances.$NAMESPACE.svc.$FED_2_SMCP_NAME-imports.local
          weight: 100
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: insurances.prod-travel-agency.svc.cluster.local
            subset: v1
          weight: 100" |oc apply -f -