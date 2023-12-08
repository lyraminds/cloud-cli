
RG=${1-$RESOURCE_GROUP}
DO=${2-$DOMAIN_NAME}
DNSPVT=${3-$DNS_PRIVATE}
#TODO
source ./util

PD="private.${DO}"
C="az network private-dns zone create -g ${RG} -n ${PD}"
isok && ./run-cmd "${C}" 

C="az network private-dns link vnet create -g ${RG} -n ${DNSPVT} -z ${PD} -v ${VNET_NAME} -e true"
isok && ./run-cmd "${C}" 


# az role assignment list --role Owner --scope /subscriptions/46107353-1b4b-43d9-bcb5-0542726f5894/resourceGroups/rg-demo-dev-westus2-001/providers/Microsoft.ContainerRegistry/registries/crdemodev001
# ID=$(az acr show -n crdemodev001 -g rg-demo-dev-westus2-001 --query id -o tsv)
# E=`az role assignment list --role Owner --scope $ID`
# /subscriptions/46107353-1b4b-43d9-bcb5-0542726f5894/resourceGroups/rg-demo-dev-westus2-001/providers/Microsoft.ContainerRegistry/registries/crdemodev001

# az role assignment create --assignee "arun.vishwanathan@cleareye.ai" \
# --role "Owner" \
# --scope "/subscriptions/46107353-1b4b-43d9-bcb5-0542726f5894/resourceGroups/rg-demo-dev-westus2-001/providers/Microsoft.ContainerRegistry/registries/crdemodev001"