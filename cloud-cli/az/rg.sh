

source base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}

rlog "az group delete -n ${RG}"

# Create resource groups if it does not exist yet
if [ $(az group exists --name "$RG") == 'false' ]; then
ok && run-cmd "az group create --name $RG --location $_REGION"
fi




