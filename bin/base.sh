

# Install command based on CC_OS see default.env for posible options
# $(install "${CC_OS}")
# $(install "ubuntu")
# script generated based on environment


function install() {    
    local _OS=${1:-${CC_OS}}    
    if [ "$_OS" == "ubuntu" ]; then    
        echo "sudo apt update && sudo apt install -y"
    elif [ "$_OS" == "centos" ] || [ "$_OS" == "rhel" ] || [ "$_OS" == "amazon" ]; then    
        echo "sudo yum update && sudo yum install -y"
    elif [ "$_OS" == "alpine" ]; then    
        echo "sudo apk add --update"
    fi
}


function log(){
   local _F=${2:-${CC_SCRIPT_FILE}} 
   echo "$1" >> ${_F}
}

function rlog(){
   local _F=${2:-${CC_REMOVE_FILE}} 
   echo "$1" >> ${_F}
}

function vlog(){
   local _F=${2:-${CC_VIEW_FILE}} 
   echo "$1" >> ${_F}
}

function nlog(){
  log ""
  log "$1"
}

function info(){
  log "$1" "${CC_LOG_FILE}"
  # echo "$1"
}

function error(){
  log "${1}" "${CC_LOG_FILE}"
  echo "${1}"
export CC_ERROR=1

}

function audit(){
  log "$1" "${CC_AUDIT_FILE}"
}

function clearlog(){
  if [ "${CC_CLEAN_LOG}" == "true" ]; then
   echo "$1" > ${CC_SCRIPT_FILE}
  #  echo "$1" > ${CC_AUDIT_FILE}
   echo "$1" > ${CC_LOG_FILE} 
   echo "$1" > ${CC_REMOVE_FILE} 
   echo "$1" > ${CC_VIEW_FILE}   
  else
   info "No log is cleared, CC_CLEAN_LOG=${CC_CLEAN_LOG}"
  fi    
}

function initlog(){
# ${CC_BIN_FOLDER}
  mkdir -p ${CC_LOG_FOLDER}  ${CC_PROJECT_SRC}
  clearlog
  info "## $(date)"
  rlog "## $(date)"
  vlog "## $(date)"
  log "## $(date)"
  
  audit ""
CV=""
if [ "${CC_RESOURCE_VERSION}" != "" ]; then
CV="-${CC_RESOURCE_VERSION}"
fi
  _AC="${CC_CUSTOMER}-${CC_CUSTOMER_ENV}-${CC_REGION}${CV}"
  audit "## $(date), ${CC_ACCOUNT_LOGIN_ID}, ${_AC}, ${CC_SUBSCRIPTION}" 
}

function _exec(){
    local _MODE=${2:-${CC_MODE}} 
    if [ "${_MODE}" == "live" ]; then        
    echo "$1"
    log "$1"
    eval "${1}"    
    ok
    audit "$1"
    elif [ "${_MODE}" == "script" ]; then
      log "$1"
    else
      error "Invalid CC_MODE=${CC_MODE} Use live or script"
      exit
    fi
}


function run-install(){    
    local i=$(install "$CC_OS") 
    local c="$i $1"
    _exec "${c}"
}


function run-cmd(){    
    _exec "${1}"
}


ok() {
STATUS=$?
if [[ $STATUS -ne 0 ]] ; then
    error "ERROR CODE1=$STATUS"
    exit $STATUS;
fi
if [ "${CC_ERROR}" == "1" ] ; then
error "ERROR CODE2=1"
 exit 0;
fi 
}

function initdir(){
  if [ ! -d "${1}" ]; then
    mkdir -p "${1}"
  fi
}

installed(){
if which $1 > /dev/null
  then
      echo "true"
  else
      echo "false"      
fi
}

mask() {
        local n=3                    # number of chars to leave
        local a="${1:0:${#1}-n}"     # take all but the last n chars
        local b="${1:${#1}-n}"       # take the final n chars 
        printf "%s%s\n" "${a//?/*}" "$b"   # substitute a with asterisks
}

empty(){
  info "$2=$1"
if [ "$1" = "" ]; then    
    echo "ERROR: $2 is required";
    echo "$3";
    exit 0;
fi
}


run-git(){

H="
run-git \"http://git.company.com/companyspace\" \"myproject\" "master"
run-git \"\${CC_GIT_URL}/companyspace/Documents/_git\" \"\${PROJECT}\" 
run-git \"\${CC_GIT_URL}/companyspace\" \"\${PROJECT}\" "branch-name"
"
empty "$1" "Git url" "${H}"
empty "$2" "Git Project Name" "${H}"

local BRANCH=${3}

GCMD="${1}/${2}"
APP_SRC=${CC_PROJECT_SRC}/${4:-${2}}

if [ ! -z "${BRANCH}" ]; then
GCMD="-b ${BRANCH} ${GCMD}"
else
BRANCH="main"
fi
APP_SRC="${APP_SRC}/${BRANCH}"



info "${GCMD}"
info "${APP_SRC}"

if [ -d "$APP_SRC" ]; then

P=`pwd`
run-cmd "cd \"${APP_SRC}\""
git reset --hard
run-cmd "git pull"
run-cmd "cd \"${P}\""

else
run-cmd "git clone --depth=1 ${GCMD} ${APP_SRC}"
fi

}

function run-sleep(){
info "Sleeping for ${1} secs"
run-cmd "sleep ${1}"
}


help(){
  if [ "${1}" == "--help" ] || [ "${1}" == "-h" ] ; then
  echo "${2}"
  exit 0;
fi
}

helm-pull(){

local REPO_URL=$1
local REPO_LOCAL=$2
local REPO_APP=$3
local HELM_VERSION=$4
local UPGRADE=${5:-noupgrade}

H="
helm-pull \"https://charts.helm.sh/stable\" \"stable\" \"mysql\" \"1.6.1\" 
helm-pull \"https://prometheus-community.github.io/helm-charts\" \"prometheus-community\" \"prometheus-blackbox-exporter\" \"8.5.0\" 

"
empty "$REPO_URL" "Helm url" "${H}"
empty "$REPO_LOCAL" "Helm repo name" "${H}"
empty "$REPO_APP" "Helm componet/app name" "${H}"

local VER=""
if [ ! -z "${HELM_VERSION}" -a "${HELM_VERSION}" != " " ]; then
VER="--version ${HELM_VERSION}"
fi

# RPATH="${CC_WORKSPACE_ROOT}/work"
# if [ ! -d ${RPATH}/${REPO_APP} ]; then
# P=`pwd`
# mkdir -p ${RPATH}
# cd ${RPATH}
# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${VER} TARGET_ARCH=x86_64 sh -
# cd $P
# fi

local CPATH="${CC_HELM_CHARTS_ROOT}/versions/${REPO_APP}/${HELM_VERSION}"
local TIME=$(date '+%Y-%m-%d-%H-%M-%S')
local HELM_BACKUP=${CC_BACKUP_FOLDER}/helm-chats/${REPO_APP}_${TIME}/
if [ ! -d ${CPATH} ]; then
local P=`pwd`
mkdir -p "${CPATH}"
# mkdir -p ${CPATH}
helm repo add ${REPO_LOCAL} ${REPO_URL}
helm repo update ${REPO_LOCAL}
helm pull ${REPO_LOCAL}/${REPO_APP} ${VER} --untar --untardir ${CPATH}

mkdir -p "${HELM_BACKUP}"
if [ -d "${CC_HELM_CHARTS_ROOT}/${REPO_APP}" ]; then
mv  "${CC_HELM_CHARTS_ROOT}/${REPO_APP}" "${HELM_BACKUP}"
fi
if [ -d "${CPATH}/${REPO_APP}" ]; then
cp -R "${CPATH}/${REPO_APP}" "${CC_HELM_CHARTS_ROOT}"
fi
cd $P
fi


}

helm-install(){
run-helm "install" "$1" "$2" "$3" "$4"
}

helm-upgrade(){
run-helm "upgrade" "$1" "$2" "$3" "$4"
}

helm-delete(){
run-helm "delete" "$1" "$2" "$3" "$4"
}

helm-uninstall(){
local APP_NAME=${1}
local NS=${2}
local H="
helm-uninstall \"app-name\" \"my-namespace\" 
"
empty "$NS" "Namespace" "${H}"
empty "$APP_NAME" "App name" "${H}"

C="helm uninstall $APP_NAME --namespace=$NS"
run-cmd "${C}" 

}

run-helm(){

local ACTION=${1}
local APP_NAME=${2}
local NS=${3}
local CHART=${4}
local OVR=${5}

local H="
helm-install \"app-name\" \"my-namespace\" \"/home/user/helm-chats/maridb/\" 
helm-install \"app-name\" \"my-namespace\" \"/chart-folder\" \"/your-custom-value-file\" 
helm-install \"app-name\" \"my-namespace\" \"/home/user/helm-chats/maridb/\" \"/home/user/deploy/app-name-overrides.yaml\" 
helm-upgrade \"app-name\" \"my-namespace\" \"/home/user/helm-chats/maridb/\" \"/home/user/deploy/app-name-overrides.yaml\" 
helm-delete  \"app-name\" \"my-namespace\" \"/home/user/helm-chats/maridb/\"
"
empty "$NS" "Namespace" "${H}"
empty "$APP_NAME" "App name" "${H}"
empty "$ACTION" "Chart action install|upgrade" "${H}"

if [ "$ACTION" == "install" ] || [ "$ACTION" == "upgrade" ]; then
empty "$CHART" "Path of helm chart" "${H}"
if [ ! -d "$CHART" ]; then
error "No helm folders found at [${CHART}], define right path in xx-overrides.env"
exit;
fi
fi

SRT="-f $OVR"
if [ -z "$OVR" ]; then
    SRT=""
fi

local C="helm $ACTION $SRT $APP_NAME --namespace=${NS} $CHART"
if [ "${ACTION}" == "install" ]; then
if [[ $(helm list -A | grep ${NS} | grep ${APP_NAME}" " | wc -l) -gt 0 ]]; then 
  echo "$APP_NAME already installed in namespace ${NS}"
  log "$APP_NAME already installed in namespace $NS "
else
#install or upgrade or delete helm
./kube/ns.sh "${NS}"
run-cmd "${C}" 
run-sleep "2"
# kubectl describe pod ${APP_NAME} -n "$NS"
fi
elif [ "$ACTION" == "delete" ] || [ "$ACTION" == "uninstall" ]; then
run-cmd "helm $ACTION $APP_NAME --namespace=${NS}"
else
run-cmd "${C}" 
fi

vlog "kubectl get pods -n ${NS}"
vlog "kubectl get events -n ${NS}"
vlog "kubectl describe pod ${APP_NAME} -n ${NS}"
echo "kubectl get pods -n ${NS}"
kubectl get pods -n ${NS}


}


fqn(){
if [ ! -z "$CC_SUB_DOMAIN_SUFFIX" -a "$CC_SUB_DOMAIN_SUFFIX" != " " ]; then
if [ ! -z "${1}" ]; then
_APP="${CC_SUB_DOMAIN_SUFFIX}-${1}"
else
_APP="${CC_SUB_DOMAIN_SUFFIX}"
fi
else
_APP="${1}"
fi
echo "${_APP}"
}

fqhn(){
local vv=$(fqn ${1})
if [ ! -z "${vv}" ]; then
echo "${vv}.${CC_DOMAIN_NAME}"
else
echo "${CC_DOMAIN_NAME}"
fi
}

export CC_GEN_SECRET_FILES=""
export CC_GEN_SECRET=""
secret-add(){
local F="${CC_GEN_SECRET}/${2}"
export CC_GEN_SECRET_FILES="${CC_GEN_SECRET_FILES} --from-file=${F}"
initdir "${CC_GEN_SECRET}"
if [ ! -e "${F}" ]; then
echo -n "${1}" > "${F}"
fi
}

secret-file(){
local F="${2:-$CC_BASE_SECRET_FOLDER}"
export CC_GEN_SECRET="${F}/${1}"  
export CC_GEN_SECRET_FILES=""
# secret-add "$1" "$2" "$3"
}


export CC_GEN_ENV_FILE=""
export CC_GEN_ENV_FILEPATH=""

env-add(){
export CC_ENV_VALUE="${1}"  
export CC_ENV_NAME="${2}"
env-sub "env-value.yaml"
}

env-sub(){
# export CC_ENV_VALUE="${1}"  
# export CC_ENV_NAME="${2}"

if [ "${CC_SECRET_STORE}" == "true" ]; then
export CC_GEN_SECRET_NAME="${CC_SECRET_PROVIDER_CLASS}"
else
export CC_GEN_SECRET_NAME="${CC_GEN_ENV_FILE}-secret"
fi

DISP=`cat  ./bin/config/${1}`
DISP=`echo "${DISP}" | envsubst '${CC_ENV_VALUE}' | envsubst '${CC_ENV_NAME}' | envsubst '${CC_GEN_SECRET_NAME}'`
echo -n "${DISP}" >> "${CC_GEN_ENV_FILEPATH}"
}

env-add-secret(){
export CC_ENV_VALUE="${1}"  
export CC_SEC_KEY="${2}"
export CC_ENV_NAME="${3:-$CC_SEC_KEY}"

secret-add "$CC_ENV_VALUE" "${CC_SEC_KEY}"
export CC_ENV_VALUE="${CC_SEC_KEY}"  
env-sub "env-secret.yaml"

}

env-url(){
env-copy-secret "${1}" "local-url-port" "${2}" "${3}" "http://" "false"
}

env-url-public(){
env-copy-secret "${1}" "public-url" "${2}" "${3}" "" "https://" "false"
}

env-copy(){
env-copy-secret "${1}" "${2}" "${3}" "${4}" "" "false"
}

env-copy-secret(){

local APP_NAME="${1}"
local CC_SEC_KEY="${2}"
export CC_ENV_NAME="${3:-$CC_SEC_KEY}"
local PREFIX=${4}
local URL_PROTO=${5}
local IS_SECRET=${6:-"true"}

local F="${CC_BASE_SECRET_FOLDER}/${APP_NAME}-secret/${CC_SEC_KEY}"
if [ ! -f "${F}" ]; then
echo "====${$CC_APP_SECRET_FOLDER}/${APP_NAME}-secret/${CC_SEC_KEY}"
local F2="${$CC_APP_SECRET_FOLDER}/${APP_NAME}-secret/${CC_SEC_KEY}"
if [ ! -f "${F2}" ]; then
echo "secret not found at ${F1}"
echo "OR"
echo "secret not found at ${F2}"
exit
else
F="${F2}"
fi
fi
export CC_ENV_VALUE=`cat ${F}`
if [ -z "${CC_ENV_VALUE}" ]; then
echo "secret value is empty check ${F}"
exit
fi

if [ "${IS_SECRET}" == "true" ]; then

if [ "${CC_SECRET_STORE}" == "true" ]; then
env-add-secret "${CC_ENV_VALUE}${PREFIX}" "${CC_ENV_NAME}" "${CC_ENV_NAME}" 
else
env-add-secret "${CC_ENV_VALUE}${PREFIX}" "${CC_ENV_NAME}" "${CC_ENV_NAME}" 
fi
else
env-add "${CC_ENV_VALUE}${PREFIX}" "${CC_ENV_NAME}"
fi
}

export E_NS=""
env-file(){

export CC_GEN_SECRET=""
export E_NS="${2}"
export CC_GEN_ENV_FILE="${1}" 
export PORT="${3}" 
export SUB_DOMAIN="${4}" 

local G="${CC_APP_DEPLOY_FOLDER}/${E_NS}"
export CC_GEN_ENV_FILEPATH="${G}/${CC_GEN_ENV_FILE}.env"
initdir "${G}"
echo -n "" > "${CC_GEN_ENV_FILEPATH}"

if [ -z "${CC_GEN_SECRET}" ]; then
export CC_GEN_SECRET="${CC_GEN_ENV_FILE}-secret"
secret-file "${CC_GEN_SECRET}" "${CC_APP_SECRET_FOLDER}"

secret-add "${CC_GEN_ENV_FILE}.${E_NS}.svc.cluster.local" "local-url" 
secret-add "${PORT}" "local-port" 
secret-add "${CC_GEN_ENV_FILE}.${E_NS}.svc.cluster.local:${PORT}" "local-url-port" 

if [ ! -z "${SUB_DOMAIN}" ]; then
HNAME="$(fqhn $SUB_DOMAIN)"
secret-add "${HNAME}" "public-url" 
fi

fi


}
env-set(){
if [ ! -z "${1}" ]; then
echo -n "${1}" >> "${CC_GEN_ENV_FILEPATH}"
fi  
}
env-write(){
env-set "${1}"
if [ ! -z "${CC_GEN_SECRET}" ]; then
if [ "${CC_SECRET_STORE}" != "true" ]; then
./kube/secret.sh "${CC_GEN_SECRET_NAME}" "${E_NS}"
fi
fi
}


initfirst(){

if [ $(installed "pwgen") == "false" ]; then
run-install "pwgen"
fi
}

build-acr() {
local VER=${1}; local BRANCH=${2}; local PROJECT=${3}; local PROJECT_URL=${4}; local DOCKER_FILE=${5:-Dockerfile};local OPTIONS=${6}
run-git "${CC_GIT_URL}/${PROJECT_URL}" "${PROJECT}" "${BRANCH}"
./docker/build-acr.sh -n "${PROJECT}" -v "${VER}" -f "${DOCKER_FILE}" -o "${OPTIONS}" -b "${BRANCH}"
}

project-replace-url(){

local HNAME=$(fqhn $3)
echo "===================$HNAME"
project-replace "${1}" "${2}" "${HNAME}" "${4}" "${5}"
}

project-replace(){
local FILE=${1}
local FROM=${2}
local TO=${3}
local PROJECT=${4}
local BRANCH=${5}  


local H="
project-replace \"src/assets/appsettings.json/\" \"localhost:8080\" \"https://myapi.abc.com\" \"project-name\" \"main\"
project-replace \"file-to-replace\" \"To Replace url\" \"Replace With\" \"project-name\" \"branch-name\"

"
empty "$FILE" "FILE" "${H}"
empty "$FROM" "FROM" "${H}"
empty "$TO" "TO" "${H}"
empty "$PROJECT" "PROJECT" "${H}"
empty "$BRANCH" "BRANCH" "${H}"


APP_SRC=${CC_PROJECT_SRC}/${PROJECT}/${BRANCH}


RPATH="${APP_SRC}/${FILE}"
if [ -f ${RPATH} ]; then
log "project-replace replacing ${FROM} with ${TO} in file ${RPATH}"
sed -i "s/${FROM}/${TO}/g" "${RPATH}"
# cat "${RPATH}"
else
log "project-replace ignored. File not found ${RPATH}"
fi

}