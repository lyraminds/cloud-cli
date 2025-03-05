#!/bin/bash
HELM_NAME="rabbitmq"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=2
ACTION="install"
DISK=32Gi
SUB_DOMAIN=${APP_NAME}
OVER_WRITE="true"
#==============================================
source bin/base.sh
H="
./helm/rabbitmq.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"${DISK}\" -r \"${REPLICA_COUNT}\" 
./helm/rabbitmq.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" -h \"helm-chart-folder-name\" 

-l region name for subdomain

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:e:w:l: flag
do
info "helm/rabbitmq.sh ${flag} ${OPTARG}"
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

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}
# export CC_RABBITMQ_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local
HNAME="$(fqhn $SUB_DOMAIN $_SD_REGION)"

SECRET=${APP_NAME}-secret
if [ "${ACTION}" == "install" ]; then
secret-file "${SECRET}"
secret-add "${CC_RABBITMQ_USER_PASSWORD}" "rabbitmq-password" 
secret-add "${CC_RABBITMQ_ERLANG_COOKIE}" "rabbitmq-erlang-cookie" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local" "local-url" 
secret-add "5672" "local-port"  
secret-add "${APP_NAME}.${NS}.svc.cluster.local:5672" "local-url-port" 
secret-add "${HNAME}" "public-url" 
./kube/secret.sh "${SECRET}" "${NS}"
fi
RABITMQ_USER_PASS=`cat ${CC_BASE_SECRET_FOLDER}/${SECRET}/rabbitmq-password`

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-overrides.yaml"

if [ "${OVER_WRITE}" == "true" ] || [ ! -f "${OVR}" ]; then

echo " 
replicaCount: ${REPLICA_COUNT}

persistence:
  #managed-premium
#   storageClass: ""
  size: ${DISK}

# memoryHighWatermark:
#   enabled: true
#   type: \"relative\"
#   value: 0.6

auth:
  username: \"${CC_RABBITMQ_USER}\"
  password: \"${RABITMQ_USER_PASS}\"
  existingPasswordSecret: \"$SECRET\"
  existingErlangSecret: \"$SECRET\"

livenessProbe:
  enabled: true
  initialDelaySeconds: 320
  timeoutSeconds: 20
  periodSeconds: 30
  failureThreshold: 6
  successThreshold: 1
readinessProbe:
  enabled: true
  initialDelaySeconds: 120
  timeoutSeconds: 20
  periodSeconds: 30
  failureThreshold: 3
  successThreshold: 1

clustering:
  forceBoot: true
extraEnvVars: 
  - name: \"LOG_LEVEL\"
    value: \"ERROR\" 

      " > ${OVR}  

if [ ! -f "${CC_RABBITMQ_DEFINITION}" ]; then
echo "####################### WARNING ##############################"
echo "No rabbitmq definitions found at [${CC_RABBITMQ_DEFINITION}], define right path at [CC_RABBITMQ_DEFINITION] in xx-overrides.env"
echo "Will continue with out rabbitmq definitions in 5 sec..."
echo "####################### WARNING ##############################"
sleep "5"
else
echo "
extraSecrets:
  load-definition:
    load_definition.json: |
      " >> ${OVR}  
cat ${CC_RABBITMQ_DEFINITION} >> ${OVR}
echo "
loadDefinition:
  enabled: true
  existingSecret: load-definition
extraConfiguration: |
  load_definitions = /app/load_definition.json
 " >> ${OVR}   
fi

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}" "TAB0"

fi

run-helm "${ACTION}" "${APP_NAME}" "${NS}" "${HELM_FOLDER}" "$OVR"
run-sleep "2"


if [ "${ACTION}" == "install" ]; then
./kube/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:15672" "${SUB_DOMAIN}" "${CC_BASE_DEPLOY_FOLDER}" "apply" "BEHIND_L7" "${_SD_REGION}"
fi
export CC_ENV_APPEND_HOST_MAPPING=''
# trap cleanup EXIT
vlog "kubectl -n "$NS" describe service ${APP_NAME}"


