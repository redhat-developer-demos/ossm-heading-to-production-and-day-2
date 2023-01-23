#!/bin/bash

SM_CP_NS=$1

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Namespace                      : '$SM_CP_NS
echo '---------------------------------------------------------------------------'

echo "Scale down to [0] Prometheus PODs"
echo "---------------------------------"
oc -n $SM_CP_NS scale --replicas=0 deployment/prometheus
echo
sleep 5
oc get deployment prometheus
echo
echo "Current SMCP Prometheus Arguments"
echo "---------------------------------"
oc -n $SM_CP_NS get deployment prometheus -o=json | jq '.spec.template.spec.containers[1].args'
echo
sleep 5
echo "Update to keep Prometheus metrics for up to 1 week before discarding"
echo "--------------------------------------------------------------------"
oc -n $SM_CP_NS patch deployment prometheus --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/1/args", "value": ["--storage.tsdb.retention.time=168h","--storage.tsdb.path=/prometheus","--config.file=/etc/prometheus/prometheus.yml","--discovery.member-roll-name=default","--discovery.member-roll-namespace='${SM_CP_NS}'"]}]'
echo
sleep 5
echo "Current SMCP Prometheus Arguments"
echo "---------------------------------"
oc -n $SM_CP_NS get deployment prometheus -o=json | jq '.spec.template.spec.containers[1].args'
echo
sleep 5
echo "Adding Persistence Volume for Prometheus metric storage"
echo "-------------------------------------------------------"
oc -n $SM_CP_NS set volume deployment/prometheus --add --name=prometheus-k8s-db -t pvc --claim-name=prometheus-db-pvc --claim-size=10Gi --overwrite
echo
sleep 7
oc describe deployment prometheus |grep -A 3 prometheus-k8s-db
echo
sleep 5
echo "PVC status & Scale up Prometheus Deployment to [1] POD"
echo "-------------------------------------------------------"
oc get pvc -n $SM_CP_NS
oc -n $SM_CP_NS scale --replicas=1 deployment/prometheus

echo
sleep 5
echo "Verify Prometheus POD"
echo "-------------------------------------------------------"
echo "oc -n $SM_CP_NS wait --for=condition=ready pod -l app=prometheus "
oc -n $SM_CP_NS wait --for=condition=ready pod -l app=prometheus
echo
echo
oc get deployment prometheus
