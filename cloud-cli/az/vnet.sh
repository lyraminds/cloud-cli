VNET=${1:-$CC_VNET_NAME}
SNET=${2:-$CC_SUBNET_NAME}
RG=${3:-$CC_RESOURCE_GROUP_NAME}

source base.sh
# --subnet-prefixes $SUBNET_PREFIX \
# --route-table $ROUTE_TABLE_NAME

rlog "az network vnet delete -g ${RG} -n ${VNET}"

E=`az network vnet list -g ${RG} --query "[?name=='${VNET}']"`
if [ "${E}" == "[]" ]; then

C="az network vnet create -g ${RG} -n ${VNET} \
--address-prefix ${CC_VNET_PREFIX} \
--subnet-name ${SNET} \
--subnet-prefixes ${CC_SUBNET_PREFIX} \
--tags ${CC_TAGS}
"
echo "$C"
ok && run-cmd "$C"

fi
vlog "az network vnet list -g ${RG} --query "[?name==\'${VNET}\']""



#ok && run-cmd "$C"


