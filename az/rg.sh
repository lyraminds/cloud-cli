

source bin/base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}

ok && rlog "az group delete -n ${RG}"

E=`az group list --query "[?name=='${RG}']"`
if [ "${E}" == "[]" ]; then
ok && run-cmd "az group create --name $RG --location $_REGION"
fi

vlog "az group list --query \"[?name=='${RG}']\""


