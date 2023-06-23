#!/bin/bash

PROJECTNAME=$1

set -e

echo ""


oc get project $PROJECTNAME  -o jsonpath='{.metadata.labels}' |jq

