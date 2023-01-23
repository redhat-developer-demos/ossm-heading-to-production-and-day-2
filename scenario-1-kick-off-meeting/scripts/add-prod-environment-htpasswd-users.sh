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
echo '    Add Users for Prod Environment purpose into `$HTPASSD_SECRET_NAME`'
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
echo
echo "And add new users (username/password)"
echo "-------------------------------"
echo "craig/craig"
htpasswd -bB users.htpasswd craig craig

echo "Update $HTPASSD_SECRET_NAME secret"
echo "-------------------------------"
oc create secret generic $HTPASSD_SECRET_NAME --from-file=htpasswd=users.htpasswd --dry-run=client -o yaml -n openshift-config | oc replace -f -
