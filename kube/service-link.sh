#!/bin/bash
APP_NAME=""
NS=""
ACTION="apply"
SERVICE_URL=""
PORT=""


source bin/base.sh
H="
./kube/service-link.sh -a \"apply\" -s \"common-namespace\" -n \"appname\" -u \"ngnix.namespace.svc.local\" -p \"80\"   
./kube/service-link.sh -a \"apply|create|delete|replace\" -n \"app-name\" -s \"common-namespace\" -u \"service-url-to-link\" -p \"port\"  

"

help "${1}" "${H}"

while getopts a:p:n:s:u: flag
do
info "kube/service-link.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) PORT=${OPTARG};;
        s) NS=${OPTARG};;
        a) ACTION=${OPTARG};;
        u) SERVICE_URL=${OPTARG};;
    esac
done



empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
# empty "$PORT" "PORT" "$H"
empty "$ACTION" "ACTION" "$H"
# empty "$SERVICE_URL" "SERVICE_URL" "$H"

./kube/ns.sh "${NS}"

if [ -z ${SERVICE_URL} ]; then
SERVICE_URL=`cat ${CC_BASE_SECRET_FOLDER}/${APP_NAME}-secret/${APP_NAME}-local-url`
fi
if [ -z ${PORT} ]; then
PORT=`cat ${CC_BASE_SECRET_FOLDER}/${APP_NAME}-secret/${APP_NAME}-local-port`
fi

DPF="${CC_APP_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-link.yaml"


echo " 
######################## ${APP_NAME} Service Link ###########################
kind: Service
apiVersion: v1
metadata:
  name: ${APP_NAME}
  namespace: ${NS}
spec:
  type: ExternalName
  externalName: ${SERVICE_URL}
  ports:
  - port: ${PORT}

    " > ${OVR}

if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "create" ] || [ "${ACTION}" == "replace" ]; then
run-cmd "kubectl ${ACTION} -f ${OVR}"
fi


rlog "kubectl -n $NS delete service/${APP_NAME}"