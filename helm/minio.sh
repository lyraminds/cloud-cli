#!/bin/bash
HELM_NAME="minio"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=4
ACTION="install"
SUB_DOMAIN=${APP_NAME}
DISK=16Gi
#==============================================
source bin/base.sh
H="
./helm/minio.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"16Gi\" -r \"4\" 
./helm/minio.sh -a \"install|upgrade|uninstall\" -h \"helm-chart-folder-name\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:e: flag
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
HNAME="$(fqhn $PUBLIC_SUB_DOMAIN)"

export CC_MINIO_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local
export CC_MINIO_PUBLIC_URL=https://${HNAME}

SECRET=${APP_NAME}-secret
OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-overrides.yaml"

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

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

if [ "${ACTION}" == "install" ]; then
# ./kube/ns.sh $NS
# fi

#define secret and create
secret-file "${SECRET}" "${CC_MINIO_ROOT_USER}" "root-user" 
secret-add "${SECRET}" "${CC_MINIO_ROOT_PASSWORD}" "root-password" 
./kube/secret.sh "${SECRET}" "${NS}"

fi
run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./helm/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:9000" "${SUB_DOMAIN}"
./helm/emissary-host-mapping.sh "${PUBLIC_APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:9001" "${PUBLIC_SUB_DOMAIN}"
fi

vlog "kubectl -n "$NS" describe service ${APP_NAME}"

