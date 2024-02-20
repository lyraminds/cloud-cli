#!/bin/bash
APP_NAME="computer-vision-read-ocr"
NS=""
NPN=""
SUB_DOMAIN=""
REPLICA_COUNT=1
ACTION="apply"
IMG_URL="mcr.microsoft.com/azure-cognitive-services/vision/read:3.2"
# DISK=32Gi
SUB_DOMAIN=${APP_NAME}
PORT="5000"
PROBE="true"
MYENV=${CC_CUSTOMER_ENV}



#==============================================
source bin/base.sh
H="
./kube/microsoft-ocr.sh -a \"apply\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\"  
./kube/microsoft-ocr.sh -a \"apply|create|delete|replace\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" 

-r \"${REPLICA_COUNT}\" 
-r \"replica-count\" 
"

help "${1}" "${H}"

while getopts a:p:n:s:r:e:u: flag
do
info "kube/microsoft-ocr.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
        u) IMG_URL=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"

if [ "${ACTION}" == "install" ]; then
ACTION=apply
fi
if [ "${ACTION}" == "uninstall" ]; then
ACTION=delete
fi

EF="microsoft-ocr.yaml"
if [ ! -f "${CC_RESOURCES_ROOT}/${EF}" ]; then
DISP=`cat ./kube/config/${EF}`
DISP=`echo "${DISP}" | envsubst '${CC_MICROSOFT_OCR_ENDPOINT_URI}' | envsubst '${CC_MICROSOFT_OCR_API_KEY}'`
echo "${DISP}" > "${CC_RESOURCES_ROOT}/${EF}"   
fi
REFENV=`cat "${CC_RESOURCES_ROOT}/${EF}"`

./kube/service.sh -a "${ACTION}" -n "${APP_NAME}" -e "${SUB_DOMAIN}" -c "${PORT}" -s "${NS}" -p "${NPN}" -o "${REFENV}" -u "${IMG_URL}" -r "${REPLICA_COUNT}"



