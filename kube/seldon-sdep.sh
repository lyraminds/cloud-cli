#!/bin/bash
APP_NAME=""
NS=""
NPN=""
REPLICA_COUNT=1
ACTION="apply"
# DISK=32Gi
# SUB_DOMAIN=${APP_NAME}
INFERENCE="layoutlm"
MODEL_IMPL=""
MODEL_PATH=""

PROBE="true"

MYENV=${CC_CUSTOMER_ENV}
PREDEFINED_MODEL="s3://predefined-models/layoutlm"
# MODEL_PATH="s3://mlflow/3979f8258cbe4590b9e676adb14d3ca9/artifacts/model"
# PREDEFINED_MODEL="s3://predefined-models/layoutlm"


#==============================================
source bin/base.sh
H="
./kube/seldon-sdep.sh -a \"apply\" -s \"common-namespace\" -p \"nodepoolname\" -i \"${INFERENCE}\" -m \"${MODEL_IMPL}\" -f \"s3://mlflow/3979f8258cbe4590b9e676adb14d3ca9/artifacts/model\"  
./kube/seldon-sdep.sh -a \"apply|create|delete|replace\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -i \"inference\" -m \"model-implementation\" -f \"model-file-path\" 

-m Model implementations 
SKLEARN_SERVER | LAYOUTLM_SERVER | LAYOUTLM_CLASSIFICATION_SERVER | BERTNER_SERVER | LC_EXTRACT_TENSORFLOW | YOLO_SERVER | NAME_ADDRESS_SERVER

-r \"${REPLICA_COUNT}\" 
-r \"replica-count\" 
"

help "${1}" "${H}"

while getopts a:p:n:s:r:f:c:m: flag
do
info "kube/seldon-sdep.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        f) MODEL_PATH=${OPTARG};;
        c) INFERENCE=${OPTARG};;
        m) MODEL_IMPL=${OPTARG};;
    esac
done



empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$INFERENCE" "INFERENCE" "$H"
empty "$MODEL_IMPL" "MODEL_IMPL" "$H"
empty "$MODEL_PATH" "MODEL_PATH" "$H"


SECRET=${APP_NAME}-secret
if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "create" ] || [ "${ACTION}" == "replace" ]; then
MINIO_SERVICE_URL_PORT=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/local-url-port`
# MINIO_SERVICE_PORT=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/local-port`
MINIO_ROOT_PASSWORD=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/root-password`

secret-file "${SECRET}"
secret-add "s3" "RCLONE_CONFIG_S3_TYPE" 
secret-add "minio" "RCLONE_CONFIG_S3_PROVIDER" 
secret-add "false" "RCLONE_CONFIG_S3_ENV_AUTH" 
secret-add "${CC_MINIO_ROOT_USER}" "RCLONE_CONFIG_S3_ACCESS_KEY_ID" 
secret-add "${MINIO_ROOT_PASSWORD}" "RCLONE_CONFIG_S3_SECRET_ACCESS_KEY" 
secret-add "http://${MINIO_SERVICE_URL_PORT}" "RCLONE_CONFIG_S3_ENDPOINT" 
# secret-add "${APP_NAME}.${NS}.svc.cluster.local" "local-url" 
# secret-add "5672" "local-port"  
./kube/secret.sh "${SECRET}" "${NS}"
fi

if [ ! -f "${CC_RESOURCES_ROOT}/seldon-secret.yaml" ]; then
DISP=`cat ./kube/config/seldon-secret.yaml`
echo "${DISP}" > "${CC_RESOURCES_ROOT}/seldon-secret.yaml"   
fi
REFENV=`cat "${CC_RESOURCES_ROOT}/seldon-secret.yaml"`

DPF="${CC_APP_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-deploy.yaml"

STORAGE_CONF="
          image: seldonio/rclone-storage-initializer:1.13.1
          imagePullPolicy: IfNotPresent
          resources:
            limits:
              cpu: '200m'
              memory: 1Gi
            requests:
              cpu: 100m
              memory: 100Mi
          volumeMounts:
          # - mountPath: /tmp/ca/host-tls.crt
          #   name: host-tls
          #   readOnly: true
          - mountPath: /mnt/models
            name: ${APP_NAME}-provision-location
"
ENV_LAYOUTLM=""
ENV_PREDEFINED="
        - args:
          - ${PREDEFINED_MODEL}
          - /mnt/models
          env:
          - name: env
            value: ${MYENV}
          ${REFENV}
          name: predefined-model-initializer${STORAGE_CONF}
"
if [ "${MODEL_IMPL}" == "YOLO_SERVER" ]; then
ENV_LAYOUTLM="
          env:
          - name: MODEL_NAME
            value: MLFlowYOLOServer
          - name: YOLO_BASE_MODEL_PATH
            value: /mnt/models
"
fi
if [ "${MODEL_IMPL}" == "LAYOUTLM_SERVER" ]; then
ENV_LAYOUTLM="
          env:
          - name: MODEL_NAME
            value: MLFlowLayoutLMServer
          - name: LAYOUTLM_BASE_MODEL_PATH
            value: /mnt/models
"
fi
if [ "${MODEL_IMPL}" == "LAYOUTLM_CLASSIFICATION_SERVER" ]; then
ENV_LAYOUTLM="
          env:
          - name: MODEL_NAME
            value: MLFlowLayoutLMClassificationServer
"
ENV_PREDEFINED=""
fi

if [ "${MODEL_IMPL}" == "LC_EXTRACT_TENSORFLOW" ] ; then
ENV_LAYOUTLM="
          env:
          - name: MODEL_NAME
            value: MLFlowLCExtractServer
"
ENV_PREDEFINED=""
fi
if [ "${MODEL_IMPL}" == "NAME_ADDRESS_SERVER" ] ; then
ENV_LAYOUTLM="
          env:
          - name: MODEL_NAME
            value: MLFlowNameAddressServer
"
fi
if [ "${MODEL_IMPL}" == "BERTNER_SERVER" ] ; then
ENV_LAYOUTLM="
          env:
          - name: MODEL_NAME
            value: MLFlowBertNerServer
"
fi



echo " 
######################## ${NAME} SeldonDeployment ###########################
apiVersion: machinelearning.seldon.io/v1alpha2
kind: SeldonDeployment
metadata:
  name: ${APP_NAME}
  namespace: ${NS}
  labels:
    app: ${APP_NAME}
    deployment: sdep
    env: ${MYENV}
    # inference: layoutlm
    inference: ${INFERENCE}
spec:
  annotations:
    seldon.io/rest-timeout: '300000'
    seldon.io/ambassador-retries: '5'
    seldon.io/ambassador-circuit-breakers-max-connections: '40'
    seldon.io/ambassador-circuit-breakers-max-pending-requests: '30'
    seldon.io/ambassador-circuit-breakers-max-requests: '15'
    seldon.io/ambassador-circuit-breakers-max-retries: '5'
  name: ${APP_NAME}
  predictors:
  - componentSpecs:
    - spec:
        containers:
        - name: ${APP_NAME}${ENV_LAYOUTLM}
          # Not required for letter of credit
          # resources:
          #   requests:
          #     memory: 2560Mi
          #   limits:
          #     memory: 3072Mi

          securityContext:
            privileged: true
            runAsGroup: 0
            runAsUser: 0
          volumeMounts:
          - mountPath: /mnt/models
            name: ${APP_NAME}-provision-location
            readOnly: true
" > "${OVR}" 

if [ "${PROBE}" == "true" ]; then
echo "
          livenessProbe:
            failureThreshold: 2000000
            httpGet:
              path: /health/ping
              port: http
              scheme: HTTP
            initialDelaySeconds: 60
            periodSeconds: 5
            successThreshold: 1
          readinessProbe:
            failureThreshold: 2000000
            httpGet:
              path: /health/ping
              port: http
              scheme: HTTP
            initialDelaySeconds: 60
            periodSeconds: 5
            successThreshold: 1

    " >> $OVR   
fi

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}" "TAB4"


echo "

        initContainers:
        - args:
          - ${MODEL_PATH}
          - /mnt/models
          env:
          - name: env
            value: ${MYENV}
          ${REFENV}
          name: ${APP_NAME}-model-initializer${STORAGE_CONF}${ENV_PREDEFINED}
        volumes:
        # - hostPath:
        #     path: /etc/kubernetes/certs/ca.crt
        #     type: File
        #   name: host-tls
        - emptyDir: {}
          name: ${APP_NAME}-provision-location
    graph:
      children: []
      implementation: ${MODEL_IMPL}
      modelUri: ${MODEL_PATH}
      name: ${APP_NAME}
    name: ${APP_NAME}
    replicas: ${REPLICA_COUNT}
    svcOrchSpec: 
      env: 
        - name: SELDON_LOG_LEVEL 
          value: DEBUG
 " >> "${OVR}"


if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "create" ] || [ "${ACTION}" == "replace" ]; then

run-cmd "kubectl ${ACTION} -f ${OVR}"
vlog "kubectl -n $NS set env deployment/${APP_NAME} env=${MYENV}"

run-cmd "kubectl -n $NS logs service/${APP_NAME}-${APP_NAME}"
elif [ "${ACTION}" == "delete" ]; then
echo "removing"
# run-cmd "kubectl -n $NS delete sdep/${APP_NAME}"
# run-cmd "kubectl -n $NS delete service/${APP_NAME}-${APP_NAME}"
elif [ "${ACTION}" == "upgrade" ]; then

run-cmd "kubectl -n ${NS} set image deployment/${APP_NAME} ${APP_NAME}=${APP_IMG}"
run-cmd "kubectl -n ${NS} rollout status deployment/${APP_NAME}"

run-cmd "kubectl -n $NS logs service/${APP_NAME}-${APP_NAME}"
fi

run-cmd "kubectl -n $NS get all"

echo "kubectl -n $NS logs service/${APP_NAME}-${APP_NAME} --follow"
echo "https://${DNS}.${DOMAIN_NAME}/seldon/${NS}/${APP_NAME}/api/v1.0/predictions"
