nifi-replace(){
local BUILD_GROUP=${1}
local APP_BUILD=${CC_BUILD_FOLDER}/${BUILD_GROUP}

for f in ${APP_BUILD}/templates/*
do
echo "Processing $f file..."
nifi-config-replace "${f}"
done
}

nifi-build-acr(){
local VER=${1}; local BUILD_GROUP=${2}; local DOCKER_FILE=${3:-Dockerfile};local OPTIONS=${4}

local APP_BUILD=${CC_BUILD_FOLDER}/${BUILD_GROUP}
cp nifi/conf/${DOCKER_FILE} ${APP_BUILD}
#removing duplicate
sort ${APP_BUILD}/requirements.tmp | uniq > ${APP_BUILD}/requirements.txt
nifi-replace "${BUILD_GROUP}"

./docker/build-acr.sh -n "${BUILD_GROUP}" -v "${VER}" -f "${DOCKER_FILE}" -o "${OPTIONS}" -s "${APP_BUILD}"

}

nifi-config-replace(){

###TODO can replace with a template filne anad get from that template and replace with env or from secret

local TEMPLATE_FILE=${1}
local MINIO_SERVICE_URL=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/local-url`
local MINIO_SERVICE_PORT=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/local-port`
local MINIO_ROOT_USER=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/root-user`
local MINIO_ROOT_PASSWORD=`cat ${CC_BASE_SECRET_FOLDER}/minio-secret/root-password`

local RABBITMQ_SERVICE_URL=`cat ${CC_BASE_SECRET_FOLDER}/rabbitmq-secret/local-url`
local RABBITMQ_SERVICE_PORT=`cat ${CC_BASE_SECRET_FOLDER}/rabbitmq-secret/local-port`
local RABBITMQ_PASSWORD=`cat ${CC_BASE_SECRET_FOLDER}/rabbitmq-secret/rabbitmq-password`


sed -i "s/MINIO_URL/http:\/\/${MINIO_SERVICE_URL}:${MINIO_SERVICE_PORT}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_ACCESS_KEY/${MINIO_ROOT_USER}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_SECRET_KEY/${MINIO_ROOT_PASSWORD}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_ROOT_USER/${MINIO_ROOT_USER}/g"  ${TEMPLATE_FILE}
sed -i "s/MINIO_ROOT_PASSWORD/${MINIO_ROOT_PASSWORD}/g"  ${TEMPLATE_FILE}

sed -i "s/RABBITMQ_URL/http:\/\/${RABBITMQ_SERVICE_URL}:${RABBITMQ_SERVICE_PORT}/g"  ${TEMPLATE_FILE}
sed -i "s/RABBITMQ_USER/${CC_RABBITMQ_USER}/g"  ${TEMPLATE_FILE}
sed -i "s/RABBITMQ_PASSWORD/${RABBITMQ_PASSWORD}/g"  ${TEMPLATE_FILE}

# TODO define ingestion api url
sed -i "s/INGESTION_API_HOST/https:\/\/${SD_INGESTION_API}.${DOMAIN_NAME}/g" ${TEMPLATE_FILE}
# TODO define ingestion api url
sed -i "s/DOCUMENT_OCR_URL_1/http:\/\/${OCR_URL}:${OCR_PORT}${OCR_PREFIX}/g" ${TEMPLATE_FILE}
sed -i "s/DOCUMENT_OCR_URL_2/http:\/\/${OCR_URL}:${OCR_PORT}${OCR_PREFIX}/g" ${TEMPLATE_FILE}
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

# run-git "${CC_GIT_URL}/${PROJECT_URL}" "${PROJECT}" "${BRANCH}"
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
mkdir -p "${APP_BUILD}/${PROJECT}"

cp -R ${APP_SRC}/src/ ${APP_BUILD}/${PROJECT}
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



