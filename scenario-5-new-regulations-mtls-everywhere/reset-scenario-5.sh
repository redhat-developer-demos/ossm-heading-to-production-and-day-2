#!/bin/bash

RESET_CA=$1
RESET_AUTHZ=$2

if [[ -z $RESET_CA ]] || [[ -z $RESET_AUTHZ ]]; then
    echo "Usage:  reset-scenario-5.sh [RESET_CA RESET_AUTHZ eg. YES NO]"
    echo "Please specify the RESET_CA [YES|NO] and RESET_AUTHZ [YES|NO] reset options you want to use!📦"
    exit 1
fi

if [[ $RESET_CA == "YES" ]] ; then
  echo
  echo "-----------------------------------------------"
  echo "Mesh Operator emma SMCP Reset secret with certs"
  echo "-----------------------------------------------"
  ./login-as.sh emma
  oc -n prod-istio-system delete secret/cacerts
fi

if [[ $RESET_AUTHZ == "YES" ]] ; then
  echo
  echo "-----------------------------------------------"
  echo "Mesh Operator emma Reset Authorization Policies"
  echo "-----------------------------------------------"
  ./login-as.sh emma

  oc delete -f authz-resources/01-default-deny.yaml
  oc delete -f authz-resources/02-travel-portal-allow.yaml
  oc delete -f authz-resources/03-gto-external-travels-to-travel-agency-allow.yaml
  oc delete -f authz-resources/04-intra-travel-agency-allow.yaml
  oc delete -f authz-resources/05-travel-portal-to-travel-agency-allow.yaml
  oc delete -f authz-resources/06-gto-external-travels-only-flights-insurances-paths-allow.yaml
fi







