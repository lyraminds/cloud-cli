#!/bin/bash

KUBERNETES_VERSION=$1
KS=${2:-$CC_AKS_CLUSTER_NAME}
RG=${3:-$CC_RESOURCE_GROUP_NAME}
source bin/base.sh

if [ "$KUBERNETES_VERSION" == "" ]; then  
az aks get-upgrades \
	--name ${KS} \
	-g ${RG} \
	--output table 
fi

H="np-upgrade-version "1.27.7" 
empty "$1" "KUBERNETES_VERSION" "$H"


E=`az aks list -g ${RG} --query "[?name=='${KS}']"`

if [ "${E}" != "[]" ]; then
C="az aks upgrade \
    --resource-group ${RG} -n ${KS}" \
    --kubernetes-version ${KUBERNETES_VERSION}"
ok && run-cmd "${C}"
else
info "No cluster ${KS} found in ${RG} "
fi
