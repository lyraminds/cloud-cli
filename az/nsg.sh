
RG=${1:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh


rlog "az network nsg delete -g ${RG} -n ${CC_NSG_NAME}"

E=`az network nsg list -g ${RG} --query "[?name=='${CC_NSG_NAME}']"`

if [ "${E}" == "[]" ]; then

C="az network nsg create \
 -n ${CC_NSG_NAME} \
 -g ${RG} \
 --tags ${CC_TAGS} 
 "

ok && run-cmd "$C"

fi
vlog "az network nsg list -g ${RG} --query "[?name==\'${CC_NSG_NAME}\']""
