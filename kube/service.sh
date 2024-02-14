#!/bin/bash
APP_NAME=""
NS=""
NPN=""
REPLICA_COUNT=1
ACTION="apply"
# DISK=32Gi
SUB_DOMAIN=""

PROBE="true"

MYENV=${CC_CUSTOMER_ENV}
IMG_NAME=""
APP_IMG_URL=""
VER=""
PORT=""
# NPN=${9:-`echo "${APP_NAME}" | tr -d -`}
REFENV=""
PROTO="http"


#==============================================
source bin/base.sh
H="
./kube/service.sh -a \"apply\" -s \"common-namespace\" -p \"nodepoolname\" -i \"docker-image-url\" -n \"application-name\" -e \"sub-domain\" -c \"port\"
./kube/service.sh -a \"apply|create|delete|replace\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" 

-i image name
   mcr.microsoft.com/azure-cognitive-services/vision/read:3.2
-o Options in yaml, Example
              - name: EULA
                value: accept
              - name: billing
                value: \${CC_MICROSOFT_OCR_ENDPOINT_URI}
              - name: apikey
                value: \${CC_MICROSOFT_OCR_API_KEY}
              # - name: Storage__ObjectStore__AzureBlob__ConnectionString
              #   value: # {AZURE_STORAGE_CONNECTION_STRING}
              # - name: Queue__Azure__ConnectionString
              #   value: # {AZURE_STORAGE_CONNECTION_STRING}
          livenessProbe:
            httpGet:
              path: /ContainerLiveness
              port: 5000
            initialDelaySeconds: 60
            periodSeconds: 60
            timeoutSeconds: 20

-r \"${REPLICA_COUNT}\" 
-r \"replica-count\" 
"

help "${1}" "${H}"

while getopts a:p:n:s:r:o:c:v:e:i:u: flag
do
info "kube/service.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        o) REFENV=${OPTARG};;
        v) VER=${OPTARG};;
        c) PORT=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
        i) IMG_NAME=${OPTARG};;
        u) APP_IMG_URL=${OPTARG};;
    esac
done



empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$PORT" "PORT" "$H"


G="${CC_APP_DEPLOY_FOLDER}/${NS}"
export CC_GEN_ENV_FILEPATH="${G}/${APP_NAME}.env"

if [ -z "${REFENV}" ]; then
if [ -f "${CC_GEN_ENV_FILEPATH}" ]; then
REFENV=`cat "${CC_GEN_ENV_FILEPATH}"`
fi
fi

# if [ -z "$SUB_DOMAIN" ]; then
# SUB_DOMAIN="${APP_NAME}"
# if

# NPN=${9:-`echo "${APP_NAME}" | tr -d -`}


# export APP_IMG_URL=${CC_CONTAINER_REGISTRY_URL}/${APP_NAME}:${VER}

if [ -z "$APP_IMG_URL" ]; then
if [ -z "$IMG_NAME" ]; then
IMG_NAME="${APP_NAME}"
fi
export APP_IMG_URL="${CC_CONTAINER_REGISTRY_URL}/${CC_CONTAINER_IMAGE_PREFIX}${IMG_NAME}:latest"
if [ ! -z "$VER" ]; then
export APP_IMG_URL="${CC_CONTAINER_REGISTRY_URL}/${CC_CONTAINER_IMAGE_PREFIX}${IMG_NAME}:${VER}"
fi
fi

# if [ ! -z "$SECRET_NAME" ]; then
# SECRET_NAME=$APP_NAME-secret
# fi
HNAME="$(fqhn $SUB_DOMAIN)"
SECRET=${APP_NAME}-secret
if [ "${ACTION}" == "install" ]; then
secret-file "${SECRET}"
secret-add "${APP_NAME}.${NS}.svc.cluster.local" "local-url" 
secret-add "$PORT" "local-port" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local:$PORT" "local-url-port" 
secret-add "${HNAME}" "public-url" 
./kube/secret.sh "${SECRET}" "${NS}"
fi


DPF="${CC_APP_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-deploy.yaml"

echo " 
######################## Namespace, Service ${NS}, ${APP_NAME} Service ###########################
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}
  namespace: ${NS}
  labels:
    app: ${APP_NAME}
    env: ${MYENV}
spec:
  # type: LoadBalancer
  # loadBalancerIP: ${IP}
  # externalTrafficPolicy: Local
  ports:
    - port: ${PORT}
      targetPort: ${PORT}
      protocol: TCP
      name: ${PROTO}
  selector:
    app: ${APP_NAME}
    env: ${MYENV}
---

######################## ${APP_NAME} Deployment ###########################
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: ${NS}
  labels:
    app: ${APP_NAME}
    env: ${MYENV}
spec:
  replicas: ${REPLICA_COUNT}
  selector:
    matchLabels:
      app: ${APP_NAME}
      env: ${MYENV}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
        env: ${MYENV}
    spec:
      volumes:
        - name: data
          emptyDir: {}
      containers:
        - name: ${APP_NAME}
          image: ${APP_IMG_URL}
          imagePullPolicy: Always
          ports:
            - name: ${PROTO}
              containerPort: ${PORT}
              protocol: TCP
          env:
              - name: env
                value: ${MYENV}
              ${REFENV}
          resources: {}

    " > "${OVR}"



# if [ ${PROBE} = true ]; then
# echo "
#           startupProbe:
#             httpGet:
#               path: /
#               port: ${PROTO}
#             failureThreshold: 20
#             periodSeconds: 10
#           readinessProbe:
#             httpGet:
#               path: /
#               port: ${PROTO}
#             #initialDelaySeconds: 60
#             # failureThreshold: 2
#             periodSeconds: 10
#           livenessProbe:
#             httpGet:
#               path: /
#               port: ${PROTO}
#             # initialDelaySeconds: 70
#             # failureThreshold: 2
#             periodSeconds: 20    
#     "
    # >> $OVR   
# fi

# VOVR=".${GAPP}/${APP_NAME}-pvc-mount.yaml"

# if [ ${APP_NAME} = "ce-nifi2-ci-pl-ic" ]; then
# if [ -f "${VOVR}" ]; then
# cat ${VOVR} >> $OVR
# fi
# fi


#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}" "TAB3"

#storageClass: managed-premium,
# if [ ! -z ${SECRET_NAME} ]; then
# ../secret/custom "${SECRET}" "${NS}" "${SECRET_NAME}"
# fi



if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "create" ] || [ "${ACTION}" == "replace" ]; then

./kube/ns.sh "${NS}"
run-cmd "${C}" 
# run-sleep "2"

run-cmd "kubectl ${ACTION} -f ${OVR}"
run-cmd "kubectl -n $NS get deploy"
vlog "kubectl -n $NS set env deployment/${APP_NAME} env=${MYENV}"
rlog "kubectl -n $NS delete deploy ${APP_NAME}"
run-sleep "6"
# ./run-cmd "kubectl -n $NS logs service/${APP_NAME} --follow"
# run-cmd "kubectl -n $NS logs service/${APP_NAME}"

if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "create" ]; then
if [ ! -z ${SUB_DOMAIN} ]; then
./kube/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:${PORT}" "${SUB_DOMAIN}" "${CC_APP_DEPLOY_FOLDER}"

./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN}`"

fi
fi
kubectl -n $NS get service
elif [ "${ACTION}" == "upgrade" ]; then

run-cmd "kubectl -n ${NS} set image deployment/${APP_NAME} ${APP_NAME}=${IMG_NAME}"
run-cmd "kubectl -n ${NS} rollout status deployment/${APP_NAME}"
kubectl -n $NS get service

elif [ "${ACTION}" == "delete" ]; then
kube/service-uninstall.sh "${NS}" "${APP_NAME}"
fi


kubectl -n $NS get pods
vlog "kubectl -n $NS logs service/${APP_NAME}"
echo "kubectl -n $NS logs service/${APP_NAME}"

