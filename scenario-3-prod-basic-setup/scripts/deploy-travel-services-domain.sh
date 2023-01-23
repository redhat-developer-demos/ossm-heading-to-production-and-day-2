#!/bin/bash

ENV=$1
SM_CP_NS=$2
ISTIO_INGRESS_ROUTE_URL=$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)

echo '---------------------------------------------------------------------------'
echo 'Environment                                : '$ENV
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'Remote SMCP Route Name (when NO DNS)       : '$ISTIO_INGRESS_ROUTE_URL
echo '---------------------------------------------------------------------------'

sleep 5

                
echo
echo "Create deployments"
echo "-------------------------------------------------"
echo 
echo "Deploy Travel Services Domain"                

echo "##################################################################################################"
echo "# Mysql db services"
echo "# credentials: root/password"
echo "##################################################################################################"
echo "apiVersion: v1
kind: Secret
metadata:
  name: mysql-credentials
type: Opaque
data:
  rootpasswd: cGFzc3dvcmQ="|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: v1
kind: Service
metadata:
  name: mysqldb
  labels:
    app: mysqldb
spec:
  ports:
    - port: 3306
      name: tcp
  selector:
    app: mysqldb"|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysqldb-v1
  labels:
    app: mysqldb
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysqldb
      version: v1
  template:
    metadata:
      labels:
        app: mysqldb
        version: v1
    spec:
      containers:
        - name: mysqldb
          image: quay.io/kiali/demo_travels_mysqldb:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: rootpasswd
          args: ["--default-authentication-plugin","mysql_native_password"]
          volumeMounts:
            - name: var-lib-mysql
              mountPath: /var/lib/mysql
      volumes:
        - name: var-lib-mysql
          emptyDir:"|oc apply -n $ENV-travel-agency -f -

echo "##################################################################################################"
echo "# Cars services"
echo "##################################################################################################"

echo "kind: Deployment
apiVersion: apps/v1
metadata:
  name: cars-v1
spec:
  selector:
    matchLabels:
      app: cars
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
      labels:
        app: cars
        version: v1
    spec:
      containers:
        - name: cars
          image: quay.io/kiali/demo_travels_cars:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: CURRENT_SERVICE
              value: 'cars'
            - name: CURRENT_VERSION
              value: 'v1'
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: DISCOUNTS_SERVICE
              value: 'http://discounts.$ENV-travel-agency:8000'
            - name: MYSQL_SERVICE
              value: 'mysqldb.$ENV-travel-agency:3306'
            - name: MYSQL_USER
              value: 'root'
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: rootpasswd
            - name: MYSQL_DATABASE
              value: 'test'"|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: v1
kind: Service
metadata:
  name: cars
  labels:
    app: cars
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: cars"|oc apply -n $ENV-travel-agency -f -

echo "##################################################################################################"
echo "# Discounts services"
echo "##################################################################################################"
echo "kind: Deployment
apiVersion: apps/v1
metadata:
  name: discounts-v1
spec:
  selector:
    matchLabels:
      app: discounts
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
      labels:
        app: discounts
        version: v1
    spec:
      containers:
        - name: discounts
          image: quay.io/kiali/demo_travels_discounts:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: CURRENT_SERVICE
              value: 'discounts'
            - name: CURRENT_VERSION
              value: 'v1'
            - name: LISTEN_ADDRESS
              value: ':8000'"|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: v1
kind: Service
metadata:
  name: discounts
  labels:
    app: discounts
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: discounts"|oc apply -n $ENV-travel-agency -f -

echo "##################################################################################################"
echo "# Flights services"
echo "##################################################################################################"
echo "kind: Deployment
apiVersion: apps/v1
metadata:
  name: flights-v1
spec:
  selector:
    matchLabels:
      app: flights
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
      labels:
        app: flights
        version: v1
    spec:
      containers:
        - name: flights
          image: quay.io/kiali/demo_travels_flights:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: CURRENT_SERVICE
              value: 'flights'
            - name: CURRENT_VERSION
              value: 'v1'
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: DISCOUNTS_SERVICE
              value: 'http://discounts.$ENV-travel-agency:8000'
            - name: MYSQL_SERVICE
              value: 'mysqldb.$ENV-travel-agency:3306'
            - name: MYSQL_USER
              value: 'root'
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: rootpasswd
            - name: MYSQL_DATABASE
              value: 'test'"|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: v1
kind: Service
metadata:
  name: flights
  labels:
    app: flights
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: flights"|oc apply -n $ENV-travel-agency -f -

echo "##################################################################################################"
echo "# Hotels services"
echo "##################################################################################################"
echo "kind: Deployment
apiVersion: apps/v1
metadata:
  name: hotels-v1
spec:
  selector:
    matchLabels:
      app: hotels
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
      labels:
        app: hotels
        version: v1
    spec:
      containers:
        - name: hotels
          image: quay.io/kiali/demo_travels_hotels:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: CURRENT_SERVICE
              value: 'hotels'
            - name: CURRENT_VERSION
              value: 'v1'
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: DISCOUNTS_SERVICE
              value: 'http://discounts.$ENV-travel-agency:8000'
            - name: MYSQL_SERVICE
              value: 'mysqldb.$ENV-travel-agency:3306'
            - name: MYSQL_USER
              value: 'root'
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: rootpasswd
            - name: MYSQL_DATABASE
              value: 'test'"|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: v1
kind: Service
metadata:
  name: hotels
  labels:
    app: hotels
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: hotels"|oc apply -n $ENV-travel-agency -f -

echo "##################################################################################################"
echo "# Insurances services"
echo "##################################################################################################"
echo "kind: Deployment
apiVersion: apps/v1
metadata:
  name: insurances-v1
spec:
  selector:
    matchLabels:
      app: insurances
      version: v1
  replicas: 1
  template:
    metadata:
      annotations:
        readiness.status.sidecar.istio.io/applicationPorts: ""
      labels:
        app: insurances
        version: v1
    spec:
      containers:
        - name: insurances
          image: quay.io/kiali/demo_travels_insurances:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: CURRENT_SERVICE
              value: 'insurances'
            - name: CURRENT_VERSION
              value: 'v1'
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: DISCOUNTS_SERVICE
              value: 'http://discounts.$ENV-travel-agency:8000'
            - name: MYSQL_SERVICE
              value: 'mysqldb.$ENV-travel-agency:3306'
            - name: MYSQL_USER
              value: 'root'
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: rootpasswd
            - name: MYSQL_DATABASE
              value: 'test'"|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: v1
kind: Service
metadata:
  name: insurances
  labels:
    app: insurances
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: insurances"|oc apply -n $ENV-travel-agency -f -

echo "##################################################################################################"
echo "# Travels services"
echo "##################################################################################################"
echo "kind: Deployment
apiVersion: apps/v1
metadata:
  name: travels-v1
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
      labels:
        app: travels
        version: v1
    spec:
      containers:
        - name: travels
          image: quay.io/kiali/demo_travels_travels:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          securityContext:
            privileged: false
          env:
            - name: CURRENT_SERVICE
              value: 'travels'
            - name: CURRENT_VERSION
              value: 'v1'
            - name: LISTEN_ADDRESS
              value: ':8000'
            - name: FLIGHTS_SERVICE
              value: 'http://flights.$ENV-travel-agency:8000'
            - name: HOTELS_SERVICE
              value: 'http://hotels.$ENV-travel-agency:8000'
            - name: CARS_SERVICE
              value: 'http://cars.$ENV-travel-agency:8000'
            - name: INSURANCES_SERVICE
              value: 'http://insurances.$ENV-travel-agency:8000'"|oc apply -n $ENV-travel-agency -f -

echo "apiVersion: v1
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
    app: travels"|oc apply -n $ENV-travel-agency -f -

echo 
echo "Add Deployments in the mesh by injecting Jaeger Tracing and Jaeger Agent  sidecars to components"
echo "---------------------------------------------------------------------------------"
echo

oc rollout pause deployment/cars-v1 -n $ENV-travel-agency
oc patch deployment/cars-v1 -p '{"metadata":{"annotations":{"sidecar.jaegertracing.io/inject": "jaeger-small-production"}}}' -n $ENV-travel-agency
oc rollout resume deployment/cars-v1 -n $ENV-travel-agency
oc patch deployment/cars-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-agency

oc rollout pause deployment/discounts-v1 -n $ENV-travel-agency
oc patch deployment/discounts-v1 -p '{"metadata":{"annotations":{"sidecar.jaegertracing.io/inject": "jaeger-small-production"}}}' -n $ENV-travel-agency
oc rollout resume deployment/discounts-v1 -n $ENV-travel-agency
oc patch deployment/discounts-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-agency

oc rollout pause deployment/flights-v1 -n $ENV-travel-agency
oc patch deployment/flights-v1 -p '{"metadata":{"annotations":{"sidecar.jaegertracing.io/inject": "jaeger-small-production"}}}' -n $ENV-travel-agency
oc rollout resume deployment/flights-v1 -n $ENV-travel-agency
oc patch deployment/flights-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-agency

oc rollout pause deployment/hotels-v1 -n $ENV-travel-agency
oc patch deployment/hotels-v1 -p '{"metadata":{"annotations":{"sidecar.jaegertracing.io/inject": "jaeger-small-production"}}}' -n $ENV-travel-agency
oc rollout resume deployment/hotels-v1 -n $ENV-travel-agency
oc patch deployment/hotels-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-agency

oc rollout pause deployment/insurances-v1 -n $ENV-travel-agency
oc patch deployment/insurances-v1 -p '{"metadata":{"annotations":{"sidecar.jaegertracing.io/inject": "jaeger-small-production"}}}' -n $ENV-travel-agency
oc rollout resume deployment/insurances-v1 -n $ENV-travel-agency
oc patch deployment/insurances-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-agency

oc rollout pause deployment/mysqldb-v1 -n $ENV-travel-agency
oc patch deployment/mysqldb-v1 -p '{"metadata":{"annotations":{"sidecar.jaegertracing.io/inject": "jaeger-small-production"}}}' -n $ENV-travel-agency
oc rollout resume deployment/mysqldb-v1 -n $ENV-travel-agency
oc patch deployment/mysqldb-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-agency

oc rollout pause deployment/travels-v1 -n $ENV-travel-agency
oc patch deployment/travels-v1 -p '{"metadata":{"annotations":{"sidecar.jaegertracing.io/inject": "jaeger-small-production"}}}' -n $ENV-travel-agency
oc rollout resume deployment/travels-v1 -n $ENV-travel-agency
oc patch deployment/travels-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $ENV-travel-agency

