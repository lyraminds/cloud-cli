#!/bin/bash
APP_NAME=""
BUILD_ARGS=""
VER=1.0
DOCKER_FILE=Dockerfile
IMG_NAME=""
BRANCH=""
CR=${CC_CONTAINER_REGISTRY}
RG=${CC_RESOURCE_GROUP_CONTAINER_REGISTRY}
SUB=${CC_SUBSCRIPTION_CONTAINER_REGISTRY}

source bin/base.sh
H="
./docker/build-acr.sh -n \"app-name\" -b \"branch-name\" -i \"build-image-name\" -v \"${VER}\" -f \"${DOCKER_FILE}\" -o \"--build-arg NPM_TOKEN=\${NPM_TOKEN}\"
./docker/build-acr.sh -n \"app-name\" -b \"branch-name\" -i \"build-image-name\" -v \"version-no\"  -f \"docker-file-name\" -o \"options\" 

"

help "${1}" "${H}"

while getopts o:n:r:v:f:i:b: flag
do
info "docker/build-acr.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        o) BUILD_ARGS=${OPTARG};;
        v) VER=${OPTARG};;
        f) DOCKER_FILE=${OPTARG};;
        i) IMG_NAME=${OPTARG};;
        b) BRANCH=${OPTARG};;
    esac
done

if [ -z "${IMG_NAME}" ]; then
IMG_NAME=${APP_NAME}
fi

empty "$APP_NAME" "APP NAME" "$H"
empty "$BRANCH" "BRANCH NAME" "$H"
empty "$IMG_NAME" "Image name" "$H"
empty "$DOCKER_FILE" "Docker file" "$H"
empty "$VER" "VERSION" "$H"



# if [ "${PROGRAM}" = "python-model" ]; then
#  "INDEX_URL=${PYTHON_REPO} --build-arg MINIO_URL=${MINIO_PUBLIC_URL} --build-arg MINIO_ACCESS_ID=${MINIO_ACCESS_ID} --build-arg MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}"
# elif [ "${PROGRAM}" = "python" ]; then
#  "INDEX_URL=${PYTHON_REPO}"
# elif [ "${PROGRAM}" = "keycloak" ]; then
#  "KEYCLOAK_THEME_NAME=${KEYCLOAK_THEME_NAME}"
# elif [ "${PROGRAM}" = "angular" ]; then
#  "SOURCE_BRANCH=master --build-arg NPM_TOKEN=${NPM_TOKEN}" 

export APP_IMG="${CC_CONTAINER_IMAGE_PREFIX}${IMG_NAME}:latest"
if [ ! -z "$VER" ]; then
export APP_IMG="${CC_CONTAINER_IMAGE_PREFIX}${IMG_NAME}:${VER}"
fi

PW=`pwd`
BUILD_SRC=${CC_PROJECT_SRC}/${APP_NAME}/${BRANCH}/
cd ${BUILD_SRC}
C="az acr build --image ${APP_IMG} --resource-group ${RG} --subscription ${SUB} --registry ${CR} ${BUILD_ARGS} --file ${DOCKER_FILE} ."
run-cmd "${C}"

cd "${PW}"