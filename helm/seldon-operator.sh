#!/bin/bash
HELM_NAME="seldon-operator"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
# REPLICA_COUNT=2
ACTION="install"
# DISK=32Gi
# SUB_DOMAIN=${APP_NAME}
APP_VERSION=""

#================================================
#istio-system/seldon-gateway
#NAMESPACE_GATEWAY="istio-system/seldon-gateway"
#==============================================
# optional
# -d \"${DISK}\" -r \"${REPLICA_COUNT}\" 
# -d \"disk-space\" -r \"replica-count\"

source bin/base.sh
H="
./helm/seldon-operator.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -v ${APP_VERSION} 
./helm/seldon-operator.sh -a \"install|upgrade|delete|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -h \"helm-chart-folder-name\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:h:v: flag
do
info "helm/seldon-operator.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        # r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        # d) DISK=${OPTARG};;
        v) APP_VERSION=${OPTARG};;        
    esac
done



empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
# empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
# empty "$DISK" "DISK" "$H"
empty "$APP_VERSION" "APP_VERSION" "$H"

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}
export CC_SELDON_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local


OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-overrides.yaml"



if [ ! -f "${CC_SELDON_OPERATOR_DEPLOYMENT}" ]; then
echo "####################### WARNING ##############################"
echo "No seldon-operation deployment found at [${CC_SELDON_OPERATOR_DEPLOYMENT}], define right path at [CC_SELDON_OPERATOR_DEPLOYMENT] in xx-overrides.env"
echo "Configuring with default, will print a sample custom configuration for reference, modify and use..."
echo "####################### WARNING ##############################"
sleep "5"
DISP=`cat ./helm/config/seldon-operator-overrides.yaml`
echo "######################## Sample begin #######################"
echo "$DISP"
echo "######################## Sample end #########################"
echo "
ambassador:
  enabled: false
  singleNamespace: false
# When activating Istio, respecive virtual services will be created
# You must make sure you create the seldon-gateway as well
istio:
  enabled: true
  gateway: istio-system/seldon-gateway

 " > ${OVR} 

else
export CC_APP_VERSION=${APP_VERSION}
DISP=`cat  ${CC_SELDON_OPERATOR_DEPLOYMENT}`
DISP=`echo "${DISP}" | envsubst '${CC_APP_VERSION}' | envsubst '${CC_CONTAINER_REGISTRY_URL}' | envsubst '${CC_CONTAINER_IMAGE_PREFIX}'`
echo "${DISP}" > ${OVR}   
fi



#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

run-helm "${ACTION}" "${APP_NAME}" "${NS}" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

vlog "kubectl -n "${NS}" describe service ${APP_NAME}"



