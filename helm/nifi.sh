#!/bin/bash
HELM_NAME="nifi"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=1
ACTION="install"
DISK=16Gi
VER="1.14.0"
IMG="apache/nifi"
SUB_DOMAIN=${APP_NAME}
#==============================================
source bin/base.sh
H="
./helm/nifi.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"16Gi\" -i "apache/nifi" -v "1.14.0" -r \"1\" 
./helm/nifi.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -i "docker-image-name" -v "image-version" -r \"replica-count\" -h \"helm-chart-folder-name\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"
echo "helm/nifi.sh line 20 not tested TODO"
exit 0;

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:i:v:e: flag
do
info "helm/nifi.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        d) DISK=${OPTARG};;
        i) IMG=${OPTARG};;
        v) VER=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
    esac
done

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"


SECRET=${APP_NAME}-secret
OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-overrides.yaml"

echo " 
replicaCount:  ${REPLICA_COUNT}

auth:
  singleUser:
    username: \"${CC_NIFI_ADMIN}\"
    password: \"${CC_NIFI_PASSWORD}\"

properties:
  externalSecure: true    
  httpPort: 8080

service:
  httpPort: 8080

persistence:
  enabled: true

image:
  repository: ${IMG}
  tag: "${VER}"
  pullPolicy: "IfNotPresent"

    " > $OVR


# if [ "${ACTION}" == "install" ]; then
# ./kube/ns.sh "${NS}"
# fi

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./helm/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:8080" "${SUB_DOMAIN}"
fi

vlog "kubectl -n "$NS" describe service ${APP_NAME}"
























