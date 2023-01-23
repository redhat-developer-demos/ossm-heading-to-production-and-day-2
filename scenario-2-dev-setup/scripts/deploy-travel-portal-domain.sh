#!/bin/bash

ENV=$1
SM_CP_NS=$2
ISTIO_INGRESS_ROUTE_URL=$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)

echo '---------------------------------------------------------------------------'
echo 'Environemnt                                : '$ENV
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'Remote SMCP Route Name (when NO DNS)       : '$ISTIO_INGRESS_ROUTE_URL
echo '---------------------------------------------------------------------------'

sleep 10


echo
echo "Create deployments"
echo "-------------------------------------------------"
echo 
echo "Deploy Travel Portal Domain"
echo "-----------------------------"

echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: voyages
spec:
  selector:
    matchLabels:
      app: voyages
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
        proxy.istio.io/config: |
          tracing:
            zipkin:
              address: zipkin.istio-system:9411
            sampling: 10
            custom_tags:
              http.header.portal:
                header:
                  name: portal
              http.header.device:
                header:
                  name: device
              http.header.user:
                header:
                  name: user
              http.header.travel:
                header:
                  name: travel
      labels:
        app: voyages
        version: v1
    spec:
      containers:
        - name: voyages
          image: quay.io/kiali/demo_travels_portal:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: PORTAL_COORDINATES
              value: '48.861310,2.337418'
            - name: PORTAL_COUNTRY
              value: 'France'
            - name: PORTAL_NAME
              value: 'voyages.fr'
            - name: TRAVELS_AGENCY_SERVICE
              value: 'http://travels.$ENV-travel-agency:8000'"|oc apply -n $ENV-travel-portal -f -

echo 'apiVersion: v1
kind: Service
metadata:
  name: voyages
  labels:
    app: voyages
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: voyages'|oc apply -n $ENV-travel-portal -f -

echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: viaggi
spec:
  selector:
    matchLabels:
      app: viaggi
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
        proxy.istio.io/config: |
          tracing:
            zipkin:
              address: zipkin.istio-system:9411
            sampling: 10
            custom_tags:
              http.header.portal:
                header:
                  name: portal
              http.header.device:
                header:
                  name: device
              http.header.user:
                header:
                  name: user
              http.header.travel:
                header:
                  name: travel
      labels:
        app: viaggi
        version: v1
    spec:
      containers:
        - name: control
          image: quay.io/kiali/demo_travels_portal:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: PORTAL_COORDINATES
              value: '41.890668,12.492194'
            - name: PORTAL_COUNTRY
              value: 'Italy'
            - name: PORTAL_NAME
              value: 'viaggi.it'
            - name: TRAVELS_AGENCY_SERVICE
              value: 'http://travels.$ENV-travel-agency:8000'"|oc apply -n $ENV-travel-portal -f -

echo 'apiVersion: v1
kind: Service
metadata:
  name: viaggi
  labels:
    app: viaggi
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: viaggi'|oc apply -n $ENV-travel-portal -f -

echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: travels
spec:
  selector:
    matchLabels:
      app: travels
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
        proxy.istio.io/config: |
          tracing:
            zipkin:
              address: zipkin.istio-system:9411
            sampling: 10
            custom_tags:
              http.header.portal:
                header:
                  name: portal
              http.header.device:
                header:
                  name: device
              http.header.user:
                header:
                  name: user
              http.header.travel:
                header:
                  name: travel
      labels:
        app: travels
        version: v1
    spec:
      containers:
        - name: control
          image: quay.io/kiali/demo_travels_portal:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: PORTAL_COORDINATES
              value: '55.956245,-3.187915'
            - name: PORTAL_COUNTRY
              value: 'United Kingdom'
            - name: PORTAL_NAME
              value: 'travels.uk'
            - name: TRAVELS_AGENCY_SERVICE
              value: 'http://travels.$ENV-travel-agency:8000'"|oc apply -n $ENV-travel-portal -f -

echo 'apiVersion: v1
kind: Service
metadata:
  name: travels
  labels:
    app: travels
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: travels'|oc apply -n $ENV-travel-portal -f -


echo 
echo "Deploy Travel Control"
echo "-----------------------------"

echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: control
spec:
  selector:
    matchLabels:
      app: control
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
      labels:
        app: control
        version: v1
    spec:
      containers:
        - name: control
          image: quay.io/kiali/demo_travels_control:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          securityContext:
            privileged: false
          env:
            - name: PORTAL_SERVICES
              value: 'voyages.fr;http://voyages.$ENV-travel-portal:8000,viaggi.it;http://viaggi.$ENV-travel-portal:8000,travels.uk;http://travels.$ENV-travel-portal:8000'"|oc apply -n $ENV-travel-control -f -

echo 'apiVersion: v1
kind: Service
metadata:
  name: control
  labels:
    app: control
spec:
  ports:
    - name: http
      port: 8080
  selector:
    app: control'|oc apply -n $ENV-travel-control -f -

echo 
echo "Add Deployments in the mesh by injecting Service Mesh sidecar to components"   
echo "---------------------------------------------------------------------------------"
echo
oc patch deployment/control -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-control

oc patch deployment/travels -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-portal
oc patch deployment/viaggi -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-portal
oc patch deployment/voyages -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-portal   

echo
echo
echo "Apply initial Istio Configs to Route external Traffic via Service Mesh Ingress"
echo "---------------------------------------------------------------------------------"

echo "Service Mesh Ingress Gateway Route"
echo "Ingress Route [$ISTIO_INGRESS_ROUTE_URL]"      
echo
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: control
  namespace: $ENV-travel-control
spec:
  hosts:
    - $ISTIO_INGRESS_ROUTE_URL
  gateways:
    - $SM_CP_NS/control-gateway
  http:
    - route:
        - destination:
            host: control.$ENV-travel-control.svc.cluster.local
            subset: v1
          weight: 100"
          
echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: control
  namespace: $ENV-travel-control
spec:
  hosts:
    - $ISTIO_INGRESS_ROUTE_URL
  gateways:
    - $SM_CP_NS/control-gateway
  http:
    - route:
        - destination:
            host: control.$ENV-travel-control.svc.cluster.local
            subset: v1
          weight: 100"|oc apply -f -          
          
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: control
  namespace: $ENV-travel-control
spec:
  host: control.$ENV-travel-control.svc.cluster.local
  subsets:
    - labels:
        version: v1
      name: v1"
      
echo "kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: control
  namespace: $ENV-travel-control
spec:
  host: control.$ENV-travel-control.svc.cluster.local
  subsets:
    - labels:
        version: v1
      name: v1"|oc apply -f -       


