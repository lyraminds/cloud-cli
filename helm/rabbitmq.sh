#!/bin/bash
HELM_NAME="rabbitmq"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=2
ACTION="install"
DISK=32Gi
#==============================================
source bin/base.sh
H="
./helm/rabbitmq.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"${DISK}\" -r \"${REPLICA_COUNT}\" 
./helm/rabbitmq.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" -h \"helm-chart-folder-name\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d: flag
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
    esac
done

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$DISK" "DISK" "$H"

export CC_RABBITMQ_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local

SECRET=${APP_NAME}-secret
#define secret and create
secret-file "${SECRET}" "${CC_RABBITMQ_USER_PASSWORD}" "rabbitmq-password" 
secret-add "${SECRET}" "${CC_RABBITMQ_ERLANG_COOKIE}" "rabbitmq-erlang-cookie" 
./kube/secret.sh "${SECRET}" "${NS}"
RABITMQ_USER_PASS=`cat ${CC_BASE_SECRET_FOLDER}/${SECRET}/rabbitmq-password`

OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-overrides.yaml"

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
  existingPasswordSecret: \"$SECRET\"
  existingErlangSecret: \"$SECRET\"
  password: \"${RABITMQ_USER_PASS}\"

extraEnvVars: 
  - name: \"LOG_LEVEL\"
    value: \"error\" 

      " > $OVR  

if [ ! -f "${CC_RABBITMQ_DEFINITION}" ]; then
echo "####################### WARNING ##############################"
error "No rabbitmq definitions found at [${CC_RABBITMQ_DEFINITION}], define right path at [CC_RABBITMQ_DEFINITION] in xx-overrides.env"
echo "Will continue with out rabbitmq definitions in 5 sec..."
echo "####################### WARNING ##############################"
sleep "5"
else
echo "
extraSecrets:
  load-definition:
    load_definition.json: |
      " >> $OVR  
cat ${CC_RABBITMQ_DEFINITION} >> $OVR
echo "
loadDefinition:
  enabled: true
  existingSecret: load-definition
extraConfiguration: |
  load_definitions = /app/load_definition.json
 " >> $OVR   
fi


# if [ "${ACTION}" == "install" ]; then
# ./kube/ns.sh $NS
# fi

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./helm/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:15672"
fi

vlog "kubectl -n "$NS" describe service ${APP_NAME}"

