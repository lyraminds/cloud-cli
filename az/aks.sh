#!/bin/bash

KS=${1:-$CC_AKS_CLUSTER_NAME}
SNET=${2:-$CC_SUBNET_NAME}
CR=${3:-$CC_CONTAINER_REGISTRY}
RG=${4:-$CC_RESOURCE_GROUP_NAME}
source bin/base.sh


A=''
#NOTE container registry assignment is disabled due to ownership issue
# https://github.com/Azure/AKS/issues/1517
# https://github.com/Azure/AKS/issues/3530
# instead use token to get access
# if [ ! -z "$CR" -a "$CR" != " " ]; then
# A="--attach-acr $CR"
# fi



E=`az aks list -g ${RG} --query "[?name=='${KS}']"`

if [ "${E}" == "[]" ]; then

SNET_ID=`az/snet-get.sh "${SNET}"`
if [ ! -z "$SNET_ID" -a "$SNET_ID" != " " ]; then
SNET_ID="--vnet-subnet-id $SNET_ID"
fi

C="az aks create -g $RG -n $KS $A -s ${CC_AKS_CLUSTER_SERVER} ${SNET_ID} $CC_AKS_CONFIG "
ok && run-cmd "${C}"
fi

rlog "az aks delete -g ${RG} -n ${KS}"
vlog "az aks get-credentials -g $RG --name $KS --admin"
vlog "az aks show -g ${RG} -n ${KS}"
vlog "#=======Update attach acr===============
ACR_ID=\$(az acr show -n "${KS}" -g "${RG}" --query id -o tsv) 
az aks update -g "${RG}" -n "${KS}" --attach-acr $ACR_ID
#============================================="

