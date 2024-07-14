
SNET=$1
ADDR=$2
VNET=${3:-$CC_VNET_NAME}
RG=${4:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh
H='
./az/snet.sh "subnetname" "Address"
./az/snet.sh "unique-virtual-subnet-name" "10.11.0.0/24"
snet prefix example 10.11.0.0/16
Your vnet name = ${VNET}
Your vnet prefix = ${CC_VNET_PREFIX}
Your default snet prefix = ${CC_SUBNET_PREFIX}

OR 

to get id of default subnet

./snet-get.sh "${CC_SUBNET_NAME}"
./snet-get.sh "${CC_SUBNET_NAME}"

'
empty "$1" "Virtual subnet name for vnet $VNET" "${H}"
empty "$2" "Address" "${H}"


E=`az network vnet subnet list -g ${RG} --query "[?name=='${SNET}']"`
if [ "${E}" == "[]" ]; then

C="az network vnet subnet create -g ${RG} -n ${SNET} \
--vnet-name ${VNET}
--address-prefix ${ADDR} \
--tags ${CC_TAGS}
"
echo "$C"
ok && run-cmd "$C"
rlog "az network vnet subnet delete -g ${RG} -n ${SNET}"
vlog "az network vnet subnet list -g ${RG} --query "[?name==\'${SNET}\']""
fi



