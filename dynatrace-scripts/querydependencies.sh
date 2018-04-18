#!/bin/bash
# Bash Script that will return the number of dependencies of the first entity that matches the tag
# This can be called from Jenkins like this
# DYNATRACE_DEPENDENCY_COUNT = sh (script: './dynatrace-scripts/querydependencies.sh SERVICE DeploymentGroup:Staging toRelationships calls', returnStatus)
# DYNATRACE_DEPENDENCY_COUNT = sh (script: './dynatrace-scripts/querydependencies.sh PROCESS-GROUP [Environment]Sample-NodeJs-Service fromRelationships runsOn', returnStatus)

# Either set your Dynatrace Token and URL in this script or pass it as Env Variables to this Shell Script
# DT_TOKEN=YOURAPITOKEN
# DT_URL=https://YOURTENANT.live.dynatrace.com

REST_URL=""
if [ "$1" = "HOST" ]; then
    REST_URL="/api/v1/entity/infrastructure/hosts"
fi
if [ "$1" = "PROCESS-GROUP" ]; then
    REST_URL="/api/v1/entity/infrastructure/process-groups"
fi
if [ "$1" = "SERVICE" ]; then
    REST_URL="/api/v1/entity/services"
fi
if [ "$1" = "APPLICATION" ]; then
    REST_URL="/api/v1/entity/applications"
fi

# do some URL Encoding as tags have some special caracters included
URL_PARAMS=$(echo "$2" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
FULL_URL=${DT_URL}${REST_URL}?tag=${URL_PARAMS}
output=$(curl -H "Content-Type: application/json" -H "Authorization: Api-Token ${DT_TOKEN}" -X GET ${FULL_URL})
echo $output >> lastdependencyjsonresult.json

# lets create a little python script that parses the response JSON
PYTHON_SCRIPT=$(cat <<EOF
import json,sys;
obj=json.load(sys.stdin);
if (len(obj) > 0) and obj[0]["$3"] and obj[0]["$3"]["$4"]:
    print(len(obj[0]["$3"]["$4"]))
else :
    print("0")
EOF
)

echo $output | python -c "$PYTHON_SCRIPT"