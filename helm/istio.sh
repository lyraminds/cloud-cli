#!/bin/bash
APP_NAME="istio"
NS="istio-system"
NPN=""
LB_IP=""
REPLICA_COUNT=1
ACTION="install"
VER=1.14.0
SUB_DOMAIN=${APP_NAME}
source bin/base.sh
H="
./helm/istio.sh -a \"install\" -p \"nodepoolname\" -r \"${REPLICA_COUNT}\" -v \"${VER}\" 
./helm/istio.sh -a \"install\" -p \"nodepoolname\" -r \"${REPLICA_COUNT}\" -v \"${VER}\" -n \"${APP_NAME}\"   
./helm/istio.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -p \"nodepoolname\" -r \"replica-count\" -v \"istio-version\"  

"

help "${1}" "${H}"

while getopts a:p:n:i:r:v:e: flag
do
info "helm/istio.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        i) LB_IP=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        v) VER=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$LB_IP" "Load balancer IP" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$VER" "ISIO VERSION" "$H"

#download version
RPATH="${CC_WORKSPACE_ROOT}/work"
if [ ! -d ${RPATH}/istio-${VER} ]; then
P=`pwd`
mkdir -p ${RPATH}
cd ${RPATH}
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${VER} TARGET_ARCH=x86_64 sh -
cd $P
fi

RPATH="${RPATH}/istio-${VER}/manifests/charts"
#copy to charts

CPATH="${CC_HELM_CHARTS_ROOT}/istio/"
if [ ! -d ${CPATH} ]; then
mkdir -p ${CPATH}
echo cp -R ${RPATH} ${CPATH}
cp -R ${RPATH} ${CPATH}
fi

if [ "${ACTION}" == "install" ]; then
./kube/ns.sh $NS
fi

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-base-overrides.yaml"
OVRD="${DPF}/${APP_NAME}-dameon-overrides.yaml"
OVRG="${DPF}/${APP_NAME}-gateway-overrides.yaml"

echo "
replicaCount: ${REPLICA_COUNT}
 " > $OVR 

./kube/set-taint.sh "${NPN}" "${OVR}" "TAB0"

echo "
replicaCount: ${REPLICA_COUNT}

pilot:
  autoscaleEnabled: true
 " > $OVRD 

./kube/set-taint.sh "${NPN}" "${OVRD}" "TAB1"

echo "
  proxy:
" >> $OVRD 

./kube/set-taint.sh "${NPN}" "${OVRD}" "TAB2"

echo "
  proxy_init:
" >> $OVRD 
./kube/set-taint.sh "${NPN}" "${OVRD}" "TAB2"


echo "

service:
  loadBalancerIP: ${LB_IP}

# podAnnotations:
#   prometheus.io/port: \"15020\"
#   prometheus.io/scrape: \"true\"
#   prometheus.io/path: \"/stats/prometheus\"
#   inject.istio.io/templates: \"gateway\"
#   sidecar.istio.io/inject: \"true\"
#   service.beta.kubernetes.io/azure-load-balancer-internal: \"true\"

 " > $OVRG 

 ./kube/set-taint.sh "${NPN}" "${OVRG}" "TAB0"

HELM_FOLDER="${CC_HELM_CHARTS_ROOT}/istio/charts"
if [ "${ACTION}" = "uninstall" ]; then

run-helm "${ACTION}" "istio-ingressgateway" "$NS" "${HELM_FOLDER}/gateway" "$OVRG"
run-helm "${ACTION}" "istiod" "$NS" "${HELM_FOLDER}/istio-control/istio-discovery" "$OVRD"
run-helm "${ACTION}" "istio-base" "$NS" "${HELM_FOLDER}/base" "$OVR"

run-cmd "helm -n ${NS} uninstall istio-ingressgateway"
run-cmd "helm -n ${NS} uninstall istiod"
run-cmd "helm -n ${NS} uninstall istio-base"
run-cmd "kubectl delete validatingwebhookconfiguration istio-validator-${NS}"

else

run-helm "${ACTION}" "istio-base" "${NS}" "${HELM_FOLDER}/base" "$OVR"
run-helm "${ACTION}" "istiod" "${NS}" "${HELM_FOLDER}/istio-control/istio-discovery" "$OVRD --wait"
# kubectl create namespace istio-ingress
run-cmd "kubectl label namespace "${NS}" istio-injection=enabled --overwrite"
run-helm "${ACTION}" "istio-ingressgateway" "${NS}" "${HELM_FOLDER}/gateway" "$OVRG  --set name=istio-ingressgateway --set labels.app=istio-ingressgateway --set labels.istio=ingressgateway --wait"

vlog "helm status istio-base -n ${NS}"
vlog "helm status istiod -n ${NS}"

export INGRESS_HOST=$(kubectl -n ${NS} get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n ${NS} get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n ${NS} get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TCP_INGRESS_PORT=$(kubectl -n ${NS} get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

log "INGRESS_HOST=${INGRESS_HOST}"
log "INGRESS_PORT=${INGRESS_PORT}"
log "SECURE_INGRESS_PORT=${SECURE_INGRESS_PORT}"
log "TCP_INGRESS_PORT=${TCP_INGRESS_PORT}"

helm ls -n ${NS}
# helm ls -n istio-ingress

vlog "kubectl -n "$NS" describe service istio-base"
fi