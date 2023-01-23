#!/bin/bash

SM_CP_NS=$1
SMCP_TENANT=$2
SMCP_PROMETHEUS_URL=$3

echo '---------------------------------------------------------------------------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo 'ServiceMesh Tenant Name                    : '$SMCP_TENANT
echo 'ServiceMesh Prometheus Route URL           : '$SMCP_PROMETHEUS_URL
echo '---------------------------------------------------------------------------------------------------------------------------------------------'
echo
echo
echo "STEP 1 - The ServiceMeshControlPlane is deployed, in [Ready] state and it has Prometheus Addon enabled."
echo "-----------------------------------------------------------------------------------------------------------"
oc project $SM_CP_NS
oc -n $SM_CP_NS get smcp
sleep 10
echo
oc -n $SM_CP_NS get deployment/prometheus
sleep 7

echo
echo
echo "STEP 2 - Scale down the Prometheus Deployment of SMCP $SMCP_TENANT"
echo "--------------------------------------------------------------------------------------------------"
oc -n $SM_CP_NS scale --replicas=0 deployment/prometheus
echo
sleep 7
oc -n $SM_CP_NS get deployment/prometheus
sleep 5

echo
echo
echo
echo "WARNING: Before moving to the next step you SHOULD have first read in the instructions (STEP 3.) how to review & update /prometheus-resources/values.yaml. If you have not done so don't proceed the next prompt until you have updated the file."
sleep 10
echo
echo
while true; do

read -p "Is the ./prometheus-resources/values.yaml File reviewed and Updated? Do you want to proceed? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done
echo
echo

echo "STEP 3 - Configure and Deploy the prometheus operator in $SM_CP_NS namespace"
echo "-----------------------------------------------------------------------------"
echo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
echo
helm repo update
echo
helm repo list
echo
echo "helm upgrade --debug --install $SMCP_TENANT  prometheus-community/kube-prometheus-stack -f ./prometheus-resources/values.yaml --skip-crds"
echo
helm upgrade --debug --install $SMCP_TENANT  prometheus-community/kube-prometheus-stack -f ./prometheus-resources/values.yaml --skip-crds
echo
echo
sleep 7
oc -n $SM_CP_NS get prometheus

echo
echo
echo "STEP 4 - Prepare to apply the same -as SMCP $SMCP_TENANT- prometheus configuration"
echo "----------------------------------------------------------------------------------"
echo
echo 'oc -n $SM_CP_NS get cm prometheus -o jsonpath="{.data.prometheus\.yml}" > ./prometheus-resources/prometheus-additional.yaml'
oc -n $SM_CP_NS get cm prometheus -o jsonpath="{.data.prometheus\.yml}" > ./prometheus-resources/prometheus-additional.yaml
sed -i '1,/scrape_configs:/d' ./prometheus-resources/prometheus-additional.yaml
cat ./prometheus-resources/prometheus-additional.yaml
sleep 7
echo
oc -n $SM_CP_NS delete secret/additional-scrape-configs
oc -n $SM_CP_NS create secret generic additional-scrape-configs --from-file=./prometheus-resources/prometheus-additional.yaml
sleep 5

echo
echo
echo "STEP 5 - Edit the dedicated prometheus-$SM_CP_NS clusterrole to allow tokenreviews and subjectaccessreviews"
echo "-----------------------------------------------------------------------------------------------------------"
echo
oc get clusterrole prometheus-$SM_CP_NS -o jsonpath='{.rules}'
echo
sleep 5
oc apply -f <(cat <(oc get clusterrole prometheus-$SM_CP_NS -o yaml) ./prometheus-resources/prometheus-clusterrole-patch.yaml)
echo
oc get clusterrole prometheus-$SM_CP_NS -o jsonpath='{.rules}'
sleep 5

echo
echo
echo "STEP 6 - Create a ClusterRoleBinding for the prometheus ServiceAccount to the prometheus-$SM_CP_NS ClusterRole"
echo "--------------------------------------------------------------------------------------------------------------"
echo
echo "apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: prometheus
    app.kubernetes.io/component: prometheus
    app.kubernetes.io/instance: $SM_CP_NS
    app.kubernetes.io/managed-by: maistra-istio-operator
    app.kubernetes.io/name: prometheus
    app.kubernetes.io/part-of: istio
    maistra.io/owner: $SM_CP_NS
    maistra.io/owner-name: $SMCP_TENANT
  name: prometheus-$SM_CP_NS
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-$SM_CP_NS
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: $SM_CP_NS"
sleep 15

echo "apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: prometheus
    app.kubernetes.io/component: prometheus
    app.kubernetes.io/instance: $SM_CP_NS
    app.kubernetes.io/managed-by: maistra-istio-operator
    app.kubernetes.io/name: prometheus
    app.kubernetes.io/part-of: istio
    maistra.io/owner: $SM_CP_NS
    maistra.io/owner-name: $SMCP_TENANT
  name: prometheus-$SM_CP_NS
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-$SM_CP_NS
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: $SM_CP_NS"| oc apply -n $SM_CP_NS -f -

sleep 4

echo
echo
echo
echo "WARNING: Before moving to the next step you SHOULD first read in the instructions (STEP 7.) how to review & update Prometheus CR (./prometheus-resources/prometheus-cr.yaml). If you have not done so don't proceed the following prompt until you have reviewed and updated the CR file first."
sleep 12
echo
echo
while true; do

read -p "Is this Prometheus CR in this script Updated? Do you want to proceed? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done
echo

echo
echo
echo "STEP 7 - Deploy the Prometheus CR in $SM_CP_NS"
echo "-----------------------------------------------"
echo
cat ./prometheus-resources/prometheus-cr.yaml
echo
sleep 15
oc -n $SM_CP_NS apply -f ./prometheus-resources/prometheus-cr.yaml
sleep 5
echo
echo
echo "------------------------------------ CHECK PROMETHEUS STATEFULSET STATUS ------------------------------------"
echo
prometheusstatefulset=0
while [ $prometheusstatefulset -le 1 ]; do
  sleep 5
  prometheusstatefulset=$(oc -n $SM_CP_NS get statefulset prometheus-prometheus -o 'jsonpath={..status.availableReplicas}')
  echo "Prometheus Stateful Set Replicas Ready => "$prometheusstatefulset
done

echo "STEP 7 - Access Prometheus UI and check metrics"
echo "-----------------------------------------------"
echo "PROMETHEUS URL: $SMCP_PROMETHEUS_URL"
echo "Verify PROMETHEUS Targets: $SMCP_PROMETHEUS_URLtargets"
echo "Verify PROMETHEUS Config: $SMCP_PROMETHEUS_URLconfig"
echo "Verify metrics for Travel Agency discounts: istio_requests_total{destination_workload=\"discounts-v1\", app=\"discounts\"}, istio_request_duration_milliseconds_count{app=\"discounts\s"}"

