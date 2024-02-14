#!/bin/bash
HELM_NAME="nifi-registry"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=1
ACTION="install"
SUB_DOMAIN=${APP_NAME}
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

while getopts a:p:n:s:r:h:e: flag
do
info "helm/nifi-registry.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
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

HNAME="$(fqhn $SUB_DOMAIN)"
SECRET=nifi-registry-secret
if [ "${ACTION}" == "install" ]; then
secret-file "${SECRET}"
secret-add "${APP_NAME}.${NS}.svc.cluster.local" "local-url" 
secret-add "18080" "local-port" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local:18080" "local-url-port" 
secret-add "${HNAME}" "public-url" 
./kube/secret.sh "${SECRET}" "${NS}"
fi


DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"`
mkdir -p "${DPF}"`
OVR="${DPF}/${APP_NAME}-overrides.yaml"

echo " 
replicaCount: ${REPLICA_COUNT}

# service:
#   port: 18080

    " > ${OVR}


# if [ "${ACTION}" == "install" ]; then
# ./kube/ns.sh "${NS}"
# fi

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "${OVR}"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./kube/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:18080" "${SUB_DOMAIN}"
fi

vlog "kubectl -n "$NS" describe service ${APP_NAME}"


