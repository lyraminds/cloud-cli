#!/bin/bash
NS=${1}
APP=${2}
IS_PUB=${3:-true}
source bin/base.sh

empty ${NS} "Namespace"
empty ${APP_NAME} "APP NAME"

C="kubectl -n ${NS} delete deployment.apps/${APP}"
run-cmd "${C}"

C="kubectl -n ${NS} delete service/${APP}"
run-cmd "${C}"

OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-deploy.yaml"
if [ -f ${OVR} ]; then
run-cmd "kubectl delete -f ${OVR} --ignore-not-found"
fi

if [ ${IS_PUB} = true ]; then
OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-host-mapping.yaml"
if [ -f ${OVR} ]; then
run-cmd "kubectl delete -f ${OVR} --ignore-not-found" 
fi
fi 

run-cmd "kubectl -n ${NS} get all"
