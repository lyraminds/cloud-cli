#!/bin/bash
HELM_NAME="nifi-registry"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=1
ACTION="install"

#==============================================
source bin/base.sh
H="
./helm/nifi-registry.sh -a \"install\" -n \"nifi-registry\" -s \"common-namespace\" -p \"nodepoolname\" -r \"1\" -h \""nifi-registry"\" 
./helm/nifi-registry.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -r \"replica-count\" -h \"helm-chart-folder-name\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 
"

help "${1}" "${H}"

while getopts a:p:n:s:r:h: flag
do
info "helm/nifi-registry.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
    esac
done

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"

export CC_NIFI_REGISTRY_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local
SECRET=${APP_NAME}-secret
OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-overrides.yaml"

echo " 
replicaCount: ${REPLICA_COUNT}

# service:
#   port: 18080

    " > $OVR


# if [ "${ACTION}" == "install" ]; then
# ./kube/ns.sh "${NS}"
# fi

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./helm/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:18080"
fi

vlog "kubectl -n "$NS" describe service ${APP_NAME}"


