export CC_VM_IP=127.0.0.1
export CC_ANSIBLE_PROJECT="AzureProject"
export CC_ANSIBLE_REPO="workspace-vm"
export CC_ANSIBLE_BRANCH="master"
export CC_PROJECT_BRANCH="stage"

ansible(){

local F="${1}"
local P="${2}"
local W="${3}"
local BASE_DIR="${CC_LOG_ROOT}/ansible/${F}"
export CC_CLIENT_NAME=$(fqn "")


if [ "${W}" == "true" ]; then

if [ ! -d "${BASE_DIR}" ]; then
mkdir -p "${BASE_DIR}"
else
local TIME=$(date '+%Y-%m-%d-%H-%M-%S')
local ANSIBLE_BACKUP="${CC_BACKUP_FOLDER}/ansible/${F}_${TIME}/"
mkdir -p "${ANSIBLE_BACKUP}"
mv  "${BASE_DIR}" "${ANSIBLE_BACKUP}"
fi

cp -R "${CC_RESOURCES_ROOT}/templates/ansible/${F}" "${CC_LOG_ROOT}/ansible/"

fi

if [ ! -d "${BASE_DIR}" ]; then
mkdir -p "${BASE_DIR}"
fi

for filename in ${CC_RESOURCES_ROOT}/templates/ansible/${F}/roles/${P}/templates/*.j2; do
copyTo "$filename" "${BASE_DIR}/roles/${P}/templates/" ".j2"
done

local IMPORT_DIR="${BASE_DIR}/pipeline"
if [ ! -d "${IMPORT_DIR}" ]; then
mkdir -p "${IMPORT_DIR}"
mkdir -p "${BASE_DIR}/inventory"
fi

IMPORT_FILE=${IMPORT_DIR}/${P}.json

copy2 "${CC_RESOURCES_ROOT}/templates/ansible/${F}/inventory/hosts" "${BASE_DIR}/inventory/hosts"
copy2 "${CC_RESOURCES_ROOT}/templates/ansible/${F}/${P}.yml" "${BASE_DIR}/${P}.yml"
copy2 "${CC_RESOURCES_ROOT}/templates/ansible/${F}/pipeline/${P}.json" "${IMPORT_FILE}"

sed -i "s/${P}/${CC_ACCOUNT_FOLDER_REPLACE}\/ansible\/${F}\/${P}/g" "${IMPORT_FILE}"
sed -i "s/ansible.cfg/${CC_ACCOUNT_FOLDER_REPLACE}\/ansible\/${F}\/ansible.cfg/g" "${IMPORT_FILE}"
}

copy2(){
local SRC="${1}"
local DEST="${2}"
local DATA=`cat "${SRC}"`
DATA=`echo "${DATA}" | envsubst '${CC_SUB_DOMAIN}' | envsubst '${CC_CLIENT_NAME}'  | envsubst '${CC_VM_IP}'  | envsubst '${CC_ANSIBLE_PROJECT}' | envsubst '${CC_ANSIBLE_REPO}' | envsubst '${CC_PROJECT_BRANCH}'| envsubst '${CC_ANSIBLE_BRANCH}'`
echo "${DATA}" > "${DEST}"
}


copyTo(){
local SRC=${1}
local DEST=${2}
local EXT_FROM=${3}
local EXT_TO=${4:-${EXT_FROM}}
mkdir -p ${DEST}

export CC_SUB_DOMAIN=$(fqhn "")

local DATA=`cat "${SRC}"`
DATA=`echo "${DATA}" | envsubst '${CC_SUB_DOMAIN}' | envsubst '${CC_CLIENT_NAME}' | envsubst '${CC_ORG_CODE}'  | envsubst '${CC_VM_IP}'`
NAME=$(basename "$filename" ${EXT_FROM})
if [ "${NAME}" == "env.js" ] || [ "${NAME}" == "httpd.conf" ]; then
echo "${DATA}" > "${DEST}/${NAME}"
elif [ "${EXT_FROM}" == ".j2" ] && [ "${EXT_TO}" == ".yaml" ]; then
DEST="${DEST}/${NAME}"
mkdir -p "${DEST}"
echo ${DEST}
echo "${DATA}" > "${DEST}/docker-compose${EXT_TO}"
elif [ "${EXT_FROM}" == ".yaml" ] && [ "${EXT_TO}" == ".yaml" ]; then
DEST="${DEST}/${NAME}"
echo "${DATA}" > "${DEST}/${EXT_TO}"
elif [ "${EXT_FROM}" == ".j2" ]; then
echo "${DATA}" > "${DEST}/${NAME}${EXT_TO}"
fi

}


ansibleToDockerCompose(){
local F="${1}"    
for filename in ${CC_RESOURCES_ROOT}/templates/ansible/${F}/*.j2; do
copyTo "$filename" "${CC_LOG_ROOT}/compose/${F}/" ".j2" ".yaml"
done
}


network(){
docker network create "${1}"     
}
