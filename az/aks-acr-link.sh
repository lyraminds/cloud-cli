#!/bin/bash

CR=${1:-$CC_CONTAINER_REGISTRY}

source bin/base.sh

run-cmd "az aks update -n ${CC_AKS_CLUSTER_NAME} -g ${CC_RESOURCE_GROUP_NAME} --attach-acr /subscriptions/${CC_SUBSCRIPTION_CONTAINER_REGISTRY}/resourceGroups/${CC_RESOURCE_GROUP_CONTAINER_REGISTRY}/providers/Microsoft.ContainerRegistry/registries/${CR}"




az aks check-acr  -n ${CC_AKS_CLUSTER_NAME} -g ${CC_RESOURCE_GROUP_NAME} --acr ${CR}
# az aks show --resource-group rg-iacces-americas-dev50-westus2 --name aks-iacces-americas-dev50-westus2 --query identityProfile.kubeletidentity.objectId

# az acr login -n criaccesamericasdev50 --expose-token