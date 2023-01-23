#!/bin/bash

USERNAME=$1

set -e

echo ""

echo "Logging in with"
echo "oc login -u $USERNAME -p $USERNAME $CLUSTER_API"
oc login -u $USERNAME -p $USERNAME $CLUSTER_API


