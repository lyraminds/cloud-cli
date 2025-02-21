#!/bin/bash
HELM_NAME="minio"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=4
ACTION="install"
DISK="16Gi"
SUB_DOMAIN=${APP_NAME}
OVER_WRITE="true"
#==============================================
source bin/base.sh
H="
./az/helm/minio.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"${DISK}\" -r \"${REPLICA_COUNT}\" 
./az/helm/minio.sh -a \"install|upgrade|uninstall\" -h \"helm-chart-folder-name\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" 

-l region name for subdomain

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:e:w:l: flag
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

if [ ! -z "${_SD_REGION}" ] && [ "${_SD_REGION}" != "" ]; then
APP_NAME=${APP_NAME}-${_SD_REGION}
_SD_REGION=${CC_CUSTOMER}-${_SD_REGION}
fi


./helm/minio.sh -n "${APP_NAME}" -s "${NS}" -p "$NPN" -a "${ACTION}" -r "${REPLICA_COUNT}" -h "${HELM_NAME}" -d "${DISK}" -e "${SUB_DOMAIN}" -w "${OVER_WRITE}" -l "${_SD_REGION}"

if [ "${ACTION}" == "install" ]; then
./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN} ${_SD_REGION}`"
./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN}-console ${_SD_REGION}`"
fi