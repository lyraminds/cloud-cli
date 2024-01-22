#!/bin/bash
HELM_NAME="rabbitmq"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=2
ACTION="install"
DISK="32Gi"
#==============================================
source bin/base.sh
H="
./az/helm/rabbitmq.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"${DISK}\" -r \"${REPLICA_COUNT}\" 
./az/helm/rabbitmq.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" -h \"helm-chart-folder-name\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d: flag
do
info "./az/helm/rabbitmq.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        d) DISK=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$DISK" "DISK" "$H"

./helm/rabbitmq.sh -n "${APP_NAME}" -s "${NS}" -p "${NPN}" -a "${ACTION}" -r "${REPLICA_COUNT}" -h "${HELM_NAME}" -d "${DISK}"

if [ "${ACTION}" == "install" ]; then
./az/afd-aks-origin.sh -n "`fqn ${APP_NAME}`"
fi