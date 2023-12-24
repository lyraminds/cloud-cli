RG=${1:-$CC_RESOURCE_GROUP_NAME}
DO=${2-$CC_DOMAIN_NAME}
DNSPVT=${3-$DNS_PRIVATE}
#TODO
source ./util

PD="private.${DO}"
C="az network private-dns zone create -g ${RG} -n ${PD}"
isok && ./run-cmd "${C}" 

C="az network private-dns link vnet create -g ${RG} -n ${DNSPVT} -z ${PD} -v ${VNET_NAME} -e true"
isok && ./run-cmd "${C}" 


# az role assignment list --role Owner --scope /subscriptions/${CC_SUBSCRIPTION}/resourceGroups/${RG}/providers/Microsoft.ContainerRegistry/registries/${CC_CONTAINER_REGISTRY}
# ID=$(az acr show -n ${CC_CONTAINER_REGISTRY} -g ${RG} --query id -o tsv)
# E=`az role assignment list --role Owner --scope $ID`
# /subscriptions/${CC_SUBSCRIPTION}/resourceGroups/${RG}/providers/Microsoft.ContainerRegistry/registries/${CC_CONTAINER_REGISTRY}

# az role assignment create --assignee "arun.vishwanathan@cleareye.ai" \
# --role "Owner" \
# --scope "/subscriptions/${CC_SUBSCRIPTION}/resourceGroups/${RG}/providers/Microsoft.ContainerRegistry/registries/${CC_CONTAINER_REGISTRY}"