#!/bin/bash
HELM_NAME="emissary-ingress"
APP_NAME="${HELM_NAME}"
NS="emissary-system"
NPN=""
LB_IP=""
REPLICA_COUNT=1
ACTION="install"
VER="2.2.2"
OVER_WRITE="true"

source bin/base.sh

H="
./helm/emissary-ingress.sh -a \"install\" -p \"nodepoolname\" -i \"202.10.20.10\" -r \"1\" 
./helm/emissary-ingress.sh -a \"install\" -n \"emissary-ingress\" -p \"nodepoolname\" -i \"202.10.20.10\" -r \"1\" -v \"${VER}\"
./helm/emissary-ingress.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -p \"nodepoolname\" -i \"load-balancer-ip\" -r \"replica-count\" -h \"helm-chart-folder-name\" 


by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 
"

help "${1}" "${H}"

while getopts a:p:n:i:r:h:v:w: flag
do
info "helm/emissary-ingress.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        i) LB_IP=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        v) VER=${OPTARG};;
        w) OVER_WRITE=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$LB_IP" "Load balancer IP" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$VER" "VERSION" "$H"

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-overrides.yaml"

if [ "${OVER_WRITE}" == "true" ] || [ ! -f "${OVR}" ]; then

echo " 
replicaCount: ${REPLICA_COUNT}
namespace:
  name: \"${NS}\"
image:
  repository: \"docker.io/emissaryingress/emissary\"
  tag: \"${VER}\"
service:
  loadBalancerIP: \"${LB_IP}\"
# createDefaultListeners: true

" > $OVR

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

fi

if [ "${ACTION}" == "install" ]; then

./kube/ns.sh $NS

run-cmd "kubectl apply -f https://app.getambassador.io/yaml/emissary/${VER}/emissary-crds.yaml"
run-cmd "kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n ${NS}"

fi

run-helm "${ACTION}" "${APP_NAME}" "${NS}" "${HELM_FOLDER}" "$OVR"
run-sleep "3"

vlog "kubectl -n "$NS" describe service ${APP_NAME}"

if [ "${ACTION}" == "install" ]; then
./helm/emissary-listener.sh ${APP_NAME} ${NS}
fi






