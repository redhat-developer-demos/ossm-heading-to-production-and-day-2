#!/bin/bash

HTPASSD_SECRET_NAME=$1

echo HTPASSD_SECRET_NAME=$HTPASSD_SECRET_NAME
if [[ -z "$HTPASSD_SECRET_NAME" ]]; then
    echo "Usage:  add-dev-environment-htpasswd-users.sh [HTTPASSD SECRET NAME eg. httpassd-secret]"
    echo "Please specify the htpasswd file to use (oc get secret  -n openshift-config |grep htpasswd) you want to use!📦"
    exit 1
fi


echo
echo
echo "###################################################################"
echo '    Add Users for Dev Environment purpose into `$HTPASSD_SECRET_NAME`'
echo "###################################################################"
echo
echo
oc get secret $HTPASSD_SECRET_NAME -o yaml  -n openshift-config > orig.htpasswd
echo "Get secret `$HTPASSD_SECRET_NAME` based users"
echo "--------------------------------------------------------------------"
cat orig.htpasswd
echo
oc get secret $HTPASSD_SECRET_NAME -ojsonpath={.data.htpasswd} -n openshift-config | base64 -d > users.htpasswd
echo
echo "users.htpasswd"
echo "-------------------------------"
cat users.htpasswd

echo "And add new users (username/password)"
echo "-------------------------------"
echo "phillip/phillip"
htpasswd -bB users.htpasswd phillip phillip
echo "emma/emma"
htpasswd -bB users.htpasswd emma emma
echo "cristina/cristina"
htpasswd -bB users.htpasswd cristina cristina
echo "farid/farid"
htpasswd -bB users.htpasswd farid farid
echo "john/john"
htpasswd -bB users.htpasswd john john
echo "mia/mia"
htpasswd -bB users.htpasswd mia mia
echo "mus/mus"
htpasswd -bB users.htpasswd mus mus

echo "Update $HTPASSD_SECRET_NAME secret"
echo "-------------------------------"
oc create secret generic $HTPASSD_SECRET_NAME --from-file=htpasswd=users.htpasswd --dry-run=client -o yaml -n openshift-config | oc replace -f -

