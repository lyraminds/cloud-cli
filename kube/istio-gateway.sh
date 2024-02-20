#!/bin/bash
APP_NAME="istio-gateway"
NS="istio-system"
ACTION="install"
SUB_DOMAIN=${APP_NAME}

#==============================================
source bin/base.sh
H="
./helm/istio-gateway.sh -a \"install\" -n "app-name" -e \"subdomain\" 
./helm/istio-gateway.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -e \"sub-domain\"

"

help "${1}" "${H}"

while getopts a:n:e: flag
do
info "helm/istio-gateway.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        a) ACTION=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
    esac
done


empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$SUB_DOMAIN" "SUB DOMAIN" "$H"

HNAME="$(fqhn $SUB_DOMAIN)"

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-istio-ingress-gateway.yaml"

echo " 
######################## ${NAME} ###########################
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${APP_NAME}
  namespace: ${NS}
  labels:
    app: ${APP_NAME}
    env: ${CC_CUSTOMER_ENV}
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - \"${HNAME}\"

" > $OVR 

# if [ ${PROBE} = true ]; then
# echo "
#   livenessProbe:
#     failureThreshold: 1000000
#     httpGet:
#       path: /health/ping
#       port: http
#       scheme: HTTP
#     initialDelaySeconds: 60
#     periodSeconds: 5
#     successThreshold: 1
#   readinessProbe:
#     failureThreshold: 1000000
#     httpGet:
#       path: /health/ping
#       port: http
#       scheme: HTTP
#     initialDelaySeconds: 60
#     periodSeconds: 5
#     successThreshold: 1

#     " >> $OVR   
# fi

if [ "${ACTION}" == "install" ]; then
./kube/ns.sh "${NS}"
fi

#toleration and taint
# ./kube/set-taint.sh "${NPN}" ${OVR} "TAB2"


#storageClass: managed-premium,
if [ "${ACTION}" = "uninstall" ]; then

# kubectl -n ${NS} delete virtualservice.networking.istio.io ${NAME}-virtual
kubectl -n ${NS} delete virtualservice.networking.istio.io ${APP_NAME} --ignore-not-found
kubectl -n ${NS} delete gateway.networking.istio.io/${APP_NAME} --ignore-not-found

elif [ $ACTION = install ]; then

run-cmd "kubectl label namespace ${NS} istio-injection=enabled --overwrite"

# if [ ! -z ${SECRET_NAME} ]; then
# ../secret/custom "${SECRET}" "${NS}" "${SECRET_NAME}"
# fi

run-sleep "1" 
run-cmd "kubectl apply -f $OVR"
kubectl get namespace -L istio-injection

vlog "kubectl get namespace -L istio-injection"
vlog "kubectl -n $NS get all"
vlog "kubectl -n $NS set env deployment/${APP_NAME} env=${MYENV}"
vlog "kubectl -n $NS delete deploy ${APP_NAME}"
vlog "waiting to finish in 5 sec..." 
run-sleep "5"
vlog "kubectl -n $NS logs service/${APP_NAME} --follow"
vlog "kubectl -n $NS logs service/${APP_NAME} --follow"
vlog "https://${HNAME}"
echo "https://${HNAME}"

elif [ $ACTION = update ]; then

run-cmd "kubectl -n $NS set image deployment/${APP_NAME} ${APP_NAME}=${APP_IMG}"
run-cmd "kubectl -n $NS rollout status deployment/${APP_NAME}"

fi

# if [ ${IS_PUB} = true ]; then
# # ./emissary-add ${ACTION} "${SUB_DOMAIN}" "${NS}" "${NAME}" "${APP_NAME}.${NS}.svc:${PORT}"
# # ./emissary-add ${ACTION} "${SUB_DOMAIN}" "${NS}" "${NAME}" "istio-ingress.istio-ingress.svc:80"

# # ./emissary-add ${ACTION} "seldon" "${NS}" "seldon" "istio-ingressgateway.istio-system.svc:80"
# fi




