
cd cloud-cli

source ./base.sh
#LOG #################
buildlog
mkdir -p ${CC_LOG_FOLDER} ${CC_AUDIT_FOLDER} ${CC_BIN_FOLDER} ${CC_PROJECT_SRC}

clearlog

_AC="${CC_CUSTOMER}-${CC_CUSTOMER_ENV}-${CC_REGION}-${CC_RESOURCE_VERSION}"

audit "$(date), ${CC_ACCOUNT_LOGIN_ID}, ${_AC}"

