SNET=$1
VNET=${2:-$CC_VNET_NAME}
RG=${3:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh

empty "$SNET" "SNET NAME" "./snet-get.sh \"\${CC_SUBNET_NAME}\"
./snet-get.sh \"${CC_SUBNET_NAME}\"
"

SNE="az network vnet subnet show -g ${RG} --vnet-name ${VNET} --name ${SNET} --query id -o tsv"
SN=`${SNE}`
echo "${SN}"