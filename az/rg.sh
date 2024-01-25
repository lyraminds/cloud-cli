

source bin/base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}

E=`az group list --query "[?name=='${RG}']"`
if [ "${E}" == "[]" ]; then
ok && run-cmd "az group create --name $RG --location $_REGION"

rlog "az group delete -n ${RG}"
vlog "az group list --query \"[?name=='${RG}']\""
fi


E=`az group list --query "[?name=='${CC_RESOURCE_GROUP_NAME_DNS}']"`
if [ "${E}" == "[]" ]; then
ok && run-cmd "az group create --name ${CC_RESOURCE_GROUP_NAME_DNS} --location $_REGION"

rlog "az group delete -n ${CC_RESOURCE_GROUP_NAME_DNS}"
vlog "az group list --query \"[?name=='${CC_RESOURCE_GROUP_NAME_DNS}']\""
fi



E=`az group list --query "[?name=='${CC_RESOURCE_GROUP_CONTAINER_REGISTRY}']"`
if [ "${E}" == "[]" ]; then
ok && run-cmd "az group create --name ${CC_RESOURCE_GROUP_CONTAINER_REGISTRY} --location $_REGION"

rlog "az group delete -n ${CC_RESOURCE_GROUP_CONTAINER_REGISTRY}"
vlog "az group list --query \"[?name=='${CC_RESOURCE_GROUP_CONTAINER_REGISTRY}']\""
fi




