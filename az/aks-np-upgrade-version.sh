#!/bin/bash

NPM=$1
KUBERNETES_VERSION=$2
KS=${3:-$CC_AKS_CLUSTER_NAME}
RG=${4:-$CC_RESOURCE_GROUP_NAME}
source bin/base.sh

 if [ "$KUBERNETES_VERSION" == "" ]; then  
az aks get-upgrades \
	--name ${KS} \
	-g ${RG} \
	--output table 
fi

H="np-upgrade-version \"nodepoolname\" \"1.27.7\""

empty "$1" "Node pool name" "$H"
empty "$2" "KUBERNETES_VERSION" "$H"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPM}']"`

if [ "${E}" != "[]" ]; then
C="az aks nodepool upgrade \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPM} \
    --kubernetes-version ${KUBERNETES_VERSION} \
    --wait"
ok && run-cmd "${C}"
else
info "No cluster ${KS} found in ${RG} "
fi
