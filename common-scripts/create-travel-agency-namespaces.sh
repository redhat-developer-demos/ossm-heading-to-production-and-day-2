#!/bin/bash

ENV=$1

set -e

echo ""

echo "oc create ns $ENV-travel-control"   
oc create ns $ENV-travel-control --dry-run=client -o yaml | oc apply -f -
echo ""
echo ""
echo "oc create ns $ENV-travel-portal"   
oc create ns $ENV-travel-portal --dry-run=client -o yaml | oc apply -f -
echo ""
echo ""
echo "oc create ns $ENV-travel-portal"   
oc create ns $ENV-travel-agency --dry-run=client -o yaml | oc apply -f -
echo ""
echo ""
echo "oc create ns $ENV-istio-system"   
oc create ns $ENV-istio-system --dry-run=client -o yaml | oc apply -f -
echo ""
echo ""

