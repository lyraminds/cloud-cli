
CR=${1:-$CC_CONTAINER_REGISTRY}
RG=${2:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh


rlog "az acr delete -g ${RG} -n ${CR}"

if [ $(az acr check-name --name "$CR" --query nameAvailable) == 'true' ]; then
C="az acr create -g $RG -n $CR --sku $CC_CONTAINER_REGISTRY_SKU --admin-enabled true --tags ${CC_TAGS}"
ok && run-cmd "$C"
fi


vlog "az acr show -g ${RG} -n ${CR}"
ACR_ID=$(az acr show -n $CR -g $RG --query id -o tsv)
vlog "az aks update -n $CR -g $RG --attach-acr $ACR_ID --verbose"
