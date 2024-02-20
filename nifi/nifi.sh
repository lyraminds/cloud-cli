source bin/base.sh

nifi-replace(){
local BUILD_GROUP=${1}
local APP_BUILD=${CC_BUILD_FOLDER}/${BUILD_GROUP}

for f in ${APP_BUILD}/templates/*
do
echo "Processing $f file..."
nifi-config-replace "${f}"
done
}

nifi-merge-prepare(){
local VER=${1}; local BUILD_GROUP=${2}; local DOCKER_FILE=${3:-Dockerfile};
    local APP_BUILD=${CC_BUILD_FOLDER}/${BUILD_GROUP}
if [ -f "${DOCKER_FILE}" ]; then
cp ${DOCKER_FILE} ${APP_BUILD}
else
cp nifi/conf/${DOCKER_FILE} ${APP_BUILD}
fi
#removing duplicate
sort ${APP_BUILD}/requirements.tmp | uniq > ${APP_BUILD}/requirements.txt
nifi-replace "${BUILD_GROUP}"
}

nifi-build-acr(){
local VER=${1}; local BUILD_GROUP=${2}; local DOCKER_FILE=${3:-Dockerfile};local OPTIONS=${4}
    local APP_BUILD=${CC_BUILD_FOLDER}/${BUILD_GROUP}


./docker/build-acr.sh -n "${BUILD_GROUP}" -v "${VER}" -f "${DOCKER_FILE}" -o "${OPTIONS}" -s "${APP_BUILD}"

}

nifi-config-replace(){


local TEMPLATE_FILE=${1}

if [ ! -f "${CC_BASE_SECRET_FOLDER}/computer-vision-read-ocr1-secret/local-url-port" ]; then
echo 'ERROR: Deploy ocr before you build nifi
./kube/microsoft-ocr.sh -n "computer-vision-read-ocr1" -s "nsdata" -e "ocr1" -p "npdata" -u "mcr.microsoft.com/azure-cognitive-services/vision/read:3.2" -r "2" -a "${ACTION}"
'
exit;
fi

if [ ! -f "${CC_BASE_SECRET_FOLDER}/computer-vision-read-ocr2-secret/local-url-port" ]; then
echo 'ERROR: Deploy ocr before you build nifi
./kube/microsoft-ocr.sh -n "computer-vision-read-ocr2" -s "nsdata" -e "ocr2" -p "npdata" -u "mcr.microsoft.com/azure-cognitive-services/vision/read:3.2" -r "2" -a "${ACTION}"
'
exit;
fi


local MINIO_PRIVATE_URL=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/local-url-port`
local MINIO_ROOT_USER=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/root-user`
local MINIO_ROOT_PASSWORD=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/root-password`

local RABBITMQ_PRIVATE_URL=`cat ${CC_BASE_SECRET_FOLDER}/rabbitmq-secret/local-url-port`
local RABBITMQ_PASSWORD=`cat ${CC_BASE_SECRET_FOLDER}/rabbitmq-secret/rabbitmq-password`


sed -i "s/MINIO_URL/http:\/\/${MINIO_PRIVATE_URL}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_ACCESS_KEY/${MINIO_ROOT_USER}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_SECRET_KEY/${MINIO_ROOT_PASSWORD}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_ROOT_USER/${MINIO_ROOT_USER}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_ROOT_PASSWORD/${MINIO_ROOT_PASSWORD}/g"  ${TEMPLATE_FILE}

sed -i "s/RABBITMQ_URL/http:\/\/${RABBITMQ_PRIVATE_URL}/g"  ${TEMPLATE_FILE}
sed -i "s/RABBITMQ_USER/${CC_RABBITMQ_USER}/g"  ${TEMPLATE_FILE}
sed -i "s/RABBITMQ_PASSWORD/${RABBITMQ_PASSWORD}/g"  ${TEMPLATE_FILE}

# echo "${CC_APP_SECRET_FOLDER}/ce-ingestion-api-secret/public-url"
if [ ! -f "${CC_APP_SECRET_FOLDER}/ce-ingestion-api-secret/public-url" ]; then
echo 'ERROR: Run this before you build nifi
env-ce-ingestion-api "ce-ingestion-api" "nsdata" "7000" "ingestion"
'
exit;
fi


local INGESTION_API_HOST=`cat ${CC_APP_SECRET_FOLDER}/ce-ingestion-api-secret/public-url`
sed -i "s/INGESTION_API_HOST/https:\/\/${INGESTION_API_HOST}/g" ${TEMPLATE_FILE}

local DOCUMENT_OCR_URL_1=`cat ${CC_BASE_SECRET_FOLDER}/computer-vision-read-ocr1-secret/local-url-port`
local DOCUMENT_OCR_URL_2=`cat ${CC_BASE_SECRET_FOLDER}/computer-vision-read-ocr2-secret/local-url-port`
local OCR_PREFIX='\/vision\/v3.2\/read\/syncAnalyze?readingOrder=natural'


sed -i "s/DOCUMENT_OCR_URL_1/http:\/\/${DOCUMENT_OCR_URL_1}${OCR_PREFIX}/g" ${TEMPLATE_FILE}
sed -i "s/DOCUMENT_OCR_URL_2/http:\/\/${DOCUMENT_OCR_URL_2}${OCR_PREFIX}/g" ${TEMPLATE_FILE}
}

nifi-merge-file(){
nifi-merge "$1" "$2" "$3" "$4" "true"
}

nifi-merge-add(){
nifi-merge "$1" "$2" "$3" "$4" "false"
}

nifi-merge() {

local PROJECT=${1}
local BRANCH=${2}
local BUILD_GROUP=${3}
local PROJECT_URL=${4}
local CLEAN=${5:-"false"}

APP_SRC=${CC_PROJECT_SRC}/${PROJECT}/${BRANCH}

run-git "${CC_GIT_URL}/${PROJECT_URL}" "${PROJECT}" "${BRANCH}"
local TIME=$(date '+%Y-%m-%d-%H-%M-%S')
local APP_BUILD=${CC_BUILD_FOLDER}/${BUILD_GROUP}
local NIFI_BACKUP=${CC_BACKUP_FOLDER}/nifi-merge/${BUILD_GROUP}_${TIME}/

if [ "${CLEAN}" == "true" ]; then
if [ -d "${APP_BUILD}" ]; then
mkdir -p "${NIFI_BACKUP}"
mv  "${APP_BUILD}" "${NIFI_BACKUP}"
fi
fi

mkdir -p "${APP_BUILD}"
mkdir -p "${APP_BUILD}/src/${PROJECT}"

cp -R ${APP_SRC}/src/* ${APP_BUILD}/src/${PROJECT}/
cp -R ${APP_SRC}/templates/ ${APP_BUILD}


if [ -f "${APP_BUILD}/requirements.tmp" ]; then
echo ""  >> ${APP_BUILD}/requirements.tmp
else
echo ""  > ${APP_BUILD}/requirements.tmp
fi
echo "## ${PROJECT}" >> ${APP_BUILD}/requirements.tmp
echo ""  >> ${APP_BUILD}/requirements.tmp
cat ${APP_SRC}/requirements.txt >>  ${APP_BUILD}/requirements.tmp

}



