#!/bin/bash
HELM_NAME="minio"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=4
ACTION="install"
SUB_DOMAIN=${APP_NAME}
DISK=16Gi
OVER_WRITE="true"
#==============================================
source bin/base.sh
H="
./helm/minio.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"16Gi\" -r \"4\" 
./helm/minio.sh -a \"install|upgrade|uninstall\" -h \"helm-chart-folder-name\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" 

-l region name for subdomain

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:e:w:l: flag
do
info "helm/minio.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        d) DISK=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
        w) OVER_WRITE=${OPTARG};;
        l) _SD_REGION=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$DISK" "DISK" "$H"

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

PUBLIC_APP_NAME="${APP_NAME}-console"
PUBLIC_SUB_DOMAIN="${SUB_DOMAIN}-console"

HNAME="$(fqhn $PUBLIC_SUB_DOMAIN $_SD_REGION)"
MINIO_PUBLIC_URL=https://${HNAME}

SECRET=${APP_NAME}-secret

if [ "${ACTION}" == "install" ]; then
secret-file "${SECRET}"
secret-add "${CC_MINIO_ROOT_USER}" "root-user" 
secret-add "${CC_MINIO_ROOT_PASSWORD}" "root-password" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local" "local-url" 
secret-add "9000" "local-port"
secret-add "${APP_NAME}.${NS}.svc.cluster.local:9000" "local-url-port" 
secret-add "${MINIO_PUBLIC_URL}" "public-url" 
./kube/secret.sh "${SECRET}" "${NS}"
fi

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-overrides.yaml"

if [ "${OVER_WRITE}" == "true" ] || [ ! -f "${OVR}" ]; then

echo " 
persistence:
  #managed-premium
  storageClass: ""
  mountPath: /data
  size: ${DISK}

mode: \"distributed\"

auth:
  existingSecret: \"${SECRET}\"

statefulset:
  replicaCount: ${REPLICA_COUNT}
  zones: 1
  drivesPerNode: 1

extraEnvVars: 
  - name: MINNIO_LOG_LEVEL 
    value: \"ERROR\" 

" > $OVR

if [ -f "${CC_MINIO_DEPLOYMENT}" ]; then
cat ${CC_MINIO_DEPLOYMENT} >> ${OVR}
fi   

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}" "TAB0"

fi

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./kube/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:9000" "${SUB_DOMAIN}" "${CC_BASE_DEPLOY_FOLDER}" "apply" "BEHIND_L7" "${_SD_REGION}"
./kube/emissary-host-mapping.sh "${PUBLIC_APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:9001" "${PUBLIC_SUB_DOMAIN}" "${CC_BASE_DEPLOY_FOLDER}" "apply" "BEHIND_L7" "${_SD_REGION}"
fi
#TODO why hostmapping delete not done may be helm delete will remove else emissary suppport delete use it here
export CC_ENV_APPEND_HOST_MAPPING=''
vlog "kubectl -n "$NS" describe service ${APP_NAME}"

