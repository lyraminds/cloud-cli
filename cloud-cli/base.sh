

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
  log "$1" "${CC_INFO_FILE}"
}

function error(){
  log "$1" "${CC_ERROR_FILE}"
}

function clearlog(){
  if [ "${CC_CLEAN_LOG}" == "true" ]; then
   echo "$1" > ${CC_SCRIPT_FILE}
   echo "$1" > ${CC_INFO_FILE}
   echo "$1" > ${CC_ERROR_FILE} 
   echo "$1" > ${CC_REMOVE_FILE} 
   echo "$1" > ${CC_VIEW_FILE}   
  else
   info "No log is cleared, CC_CLEAN_LOG=${CC_CLEAN_LOG}"
  fi    
}


function _exec(){
    local _MODE=${2:-${CC_MODE}} 
    if [ "${_MODE}" == "live" ]; then
     log "$1"
     eval "$1"     
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
    exit;
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


