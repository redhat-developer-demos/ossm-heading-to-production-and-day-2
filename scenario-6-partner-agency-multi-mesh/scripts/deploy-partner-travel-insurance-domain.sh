#!/bin/bash

NAMESPACE=$1
SM_CP_NS=$2
ISTIO_INGRESS_ROUTE_URL=$(oc get route istio-ingressgateway -o jsonpath='{.spec.host}' -n $SM_CP_NS)

echo '---------------------------------------------------------------------------'
echo 'Partner Environment                        : '$NAMESPACE
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'Remote SMCP Route Name (when NO DNS)       : '$ISTIO_INGRESS_ROUTE_URL
echo '---------------------------------------------------------------------------'

sleep 5

                
echo
echo "Create deployments"
echo "-------------------------------------------------"
echo 
echo "Deploy Partner Insurance Services Domain"                
echo
echo

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
  rootpasswd: cGFzc3dvcmQ="|oc apply -n $NAMESPACE -f -

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
    app: mysqldb"|oc apply -n $NAMESPACE -f -

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
          emptyDir:"|oc apply -n $NAMESPACE -f -

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
              value: 'http://discounts.$NAMESPACE:8000'
            - name: MYSQL_SERVICE
              value: 'mysqldb.$NAMESPACE:3306'
            - name: MYSQL_USER
              value: 'root'
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: rootpasswd
            - name: MYSQL_DATABASE
              value: 'test'"|oc apply -n $NAMESPACE -f -

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
    app: insurances"|oc apply -n $NAMESPACE -f -


echo 
echo "Add Deployments in the mesh by injecting Service Mesh (istio-proxy) sidecar to components"
echo "---------------------------------------------------------------------------------"
echo

oc patch deployment/insurances-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $NAMESPACE
oc patch deployment/mysqldb-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $NAMESPACE

