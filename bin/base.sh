

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
  log "$1" "${CC_LOG_FILE}"
  echo "$1"
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
    eval "$1"    
    ok
    audit "$1"
    elif [ "${_MODE}" == "script" ]; then
      log "$1"
    else
      error "Invalid CC_MODE=${CC_MODE} Use live or script"
    fi
}


function run-install(){    
    local i=$(install "$CC_OS") 
    local c="$i $1"
    _exec "$c"
}


function run-cmd(){    
    _exec "$1"
}


ok() {
STATUS=$?
if [[ $STATUS -ne 0 ]] ; then
    error "ERROR CODE=$STATUS"
    exit $STATUS;
fi
if [ "$CC_ERROR" == "1" ] ; then
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
run-git \"http://git.company.com/companyspace\" \"myproject\" 
run-git \"\${CC_BRANCH} \${CC_GIT_URL}/companyspace/Documents/_git\" \"\${PROJECT}\" 
run-git \"-b master \${CC_GIT_URL}/companyspace\" \"\${PROJECT}\"
"
empty "$1" "Git url" "${H}"
empty "$2" "Git Project Name" "${H}"

GCMD="${1}/${2}"
APP_SRC=${CC_PROJECT_SRC}/${3:-${2}}

info "${GCMD}"
info "${APP_SRC}"

if [ -d "$APP_SRC" ]; then

P=`pwd`
run-cmd "cd \"${APP_SRC}\""
run-cmd "git reset --hard"
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

local CPATH="${CC_HELM_CHARTS_ROOT}/${REPO_APP}/"
if [ ! -d ${CPATH} ]; then
local P=`pwd`
# mkdir -p ${CPATH}
helm repo add ${REPO_LOCAL} ${REPO_URL}
helm repo update ${REPO_LOCAL}
helm pull ${REPO_LOCAL}/${REPO_APP} ${VER} --untar --untardir ${CC_HELM_CHARTS_ROOT}
# local C="run-git ${GIT_URL} ${REPO_APP}"
# _exec "$C" "ignore"
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
run-cmd "$C" 

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

C="helm $ACTION $SRT $APP_NAME --namespace=${NS} $CHART"
if [ "$ACTION" == "install" ]; then
if [[ $(helm list -A | grep ${NS} | grep $APP_NAME" " | wc -l) -gt 0 ]]; then 
    log "$APP_NAME already installed in namespace $NS "
else
#install or upgrade or delete helm
./kube/ns.sh "${NS}"
run-cmd "$C" 
fi
elif [ "$ACTION" == "delete" ] || [ "$ACTION" == "uninstall" ]; then
run-cmd "helm $ACTION $APP_NAME --namespace=${NS}"
else
run-cmd "$C" 
fi
# run-sleep 6


}


fqn(){
if [ ! -z "$CC_SUB_DOMAIN_SUFFIX" -a "$CC_SUB_DOMAIN_SUFFIX" != " " ]; then
_APP="-${CC_SUB_DOMAIN_SUFFIX}"
fi
echo "${1}${_APP}"
}

fqhn(){
echo "$(fqn ${1}).${CC_DOMAIN_NAME}"
}

export CC_GEN_SECRET_FILES=""
secret-add(){
local G="${CC_BASE_SECRET_FOLDER}/${1}"
local F="${G}/${3}"
export CC_GEN_SECRET_FILES="${CC_GEN_SECRET_FILES} --from-file=${F}"
initdir "${G}"
if [ ! -e "${F}" ]; then
echo -n "${2}" > "${F}"
fi
}

secret-file(){
export CC_GEN_SECRET_FILES=""
secret-add "$1" "$2" "$3"
}