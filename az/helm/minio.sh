#!/bin/bash
HELM_NAME="minio"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=4
ACTION="install"
DISK="16Gi"
SUB_DOMAIN=${APP_NAME}
#==============================================
source bin/base.sh
H="
./az/helm/minio.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"${DISK}\" -r \"${REPLICA_COUNT}\" 
./az/helm/minio.sh -a \"install|upgrade|uninstall\" -h \"helm-chart-folder-name\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:e: flag
do
info "az/helm/minio.sh ${flag} ${OPTARG}"
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

./helm/minio.sh -n "${APP_NAME}" -s "${NS}" -p "$NPN" -a "${ACTION}" -r "${REPLICA_COUNT}" -h "${HELM_NAME}" -d "${DISK}" -e "${SUB_DOMAIN}"

if [ "${ACTION}" == "install" ]; then
./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN}`"
./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN}-console`"
fi