#!/bin/bash
NS=${1}
APP_NAME=${2}
IS_PUB=${3:-true}
source bin/base.sh

empty ${NS} "Namespace"
empty ${APP_NAME} "APP NAME"

#TODO not tested

C="kubectl -n ${NS} delete deployment.apps/${APP_NAME}"
run-cmd "${C}"

C="kubectl -n ${NS} delete service/${APP_NAME}"
run-cmd "${C}"

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-deploy.yaml"
if [ -f ${OVR} ]; then
run-cmd "kubectl delete -f ${OVR} --ignore-not-found"
fi

if [ ${IS_PUB} = true ]; then
OVR="${DPF}/${APP_NAME}-host-mapping.yaml"
if [ -f ${OVR} ]; then
run-cmd "kubectl delete -f ${OVR} --ignore-not-found" 
fi
fi 

run-cmd "kubectl -n ${NS} get all"
