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
OVER_WRITE="true"
#==============================================
source bin/base.sh
H="
./helm/nifi.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"16Gi\" -i "apache/nifi" -v "1.14.0" -r \"1\" 
./helm/nifi.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -i "docker-image-name" -v "image-version" -r \"replica-count\" -h \"helm-chart-folder-name\" 

-l region name for subdomain

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"
echo "helm/nifi.sh line 20 not tested TODO"
exit 0;

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:i:v:e:w:l: flag
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
        w) OVER_WRITE=${OPTARG};;
        l) _SD_REGION=${OPTARG};;
    esac
done

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"


HNAME="$(fqhn $SUB_DOMAIN $_SD_REGION)"
SECRET=${APP_NAME}-secret
if [ "${ACTION}" == "install" ]; then
secret-file "${SECRET}"
secret-add "${APP_NAME}.${NS}.svc.cluster.local" "local-url" 
secret-add "8080" "local-port" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local:8080" "local-url-port" 
secret-add "${HNAME}" "public-url" 
./kube/secret.sh "${SECRET}" "${NS}"
fi

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-overrides.yaml"

if [ "${OVER_WRITE}" == "true" ] || [ ! -f "${OVR}" ]; then
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
./kube/set-taint.sh "${NPN}" "${OVR}" "TAB0"

fi

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./kube/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:8080" "${SUB_DOMAIN}" "${CC_BASE_DEPLOY_FOLDER}" "apply" "BEHIND_L7" "${_SD_REGION}"
fi
export CC_ENV_APPEND_HOST_MAPPING=''
vlog "kubectl -n "$NS" describe service ${APP_NAME}"
























