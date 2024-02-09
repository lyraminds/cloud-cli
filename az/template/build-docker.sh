
source zlink.sh
source nifi/nifi.sh

export VERSION="1.0"

function build-keycloak-theme(){
build-acr "${APP_VERSION}" "master" "project-name" "<git-project-path>" "Dockerfile"
}

function seldon() {
local PROJECT=${1}; 
build-acr "${APP_VERSION}" "develop" "${PROJECT}" "<git-project-path>" "Dockerfile" "--build-arg INDEX_URL=${CC_PYTHON_REPO}"
}

function  build(){
echo "Building Seldon"
# build-ml "ce-inference-bert-ner"
# build-ml "ce-inference-layoutlm"
# build-ml "ce-inference-layoutlm-classification"
# build-ml "ce-inference-alert-classification"
# build-ml "ce-inference-tensorflow"
# build-ml "ce-inference-inverse-label"
# build-ml "ce-inference-name-address"

}