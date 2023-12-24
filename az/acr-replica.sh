
#for premium sku and to make a replica of acr in a different region


REGION=$1
CR=${2:-$CC_CONTAINER_REGISTRY}
RG=${3:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh

empty "$1" "Secondory Region" "./acr-replica.sh \"eastus\""

rlog "az acr replication delete -g ${RG} -r ${CR} -n ${CC_CONTAINER_REGISTRY_REPLICATION_NAME}"

E=`az acr replication list -g ${RG} -r ${CR} --query "[?name=='${CC_CONTAINER_REGISTRY_REPLICATION_NAME}']"`
if [ "${E}" == "[]" ]; then
# if [ "$CC_CONTAINER_REGISTRY_SKU" == "Premium" ]; then

C="az acr replication create -n ${CC_CONTAINER_REGISTRY_REPLICATION_NAME} -g $RG -r $CR -l $REGION"
ok && run-cmd "$C"

# fi
fi

vlog "az acr replication show -g ${RG} -r ${CR} -n ${CC_CONTAINER_REGISTRY_REPLICATION_NAME}"
