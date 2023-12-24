#!/bin/bash

NPM=$1
UPGRADE_CMDS=$2
KS=${3:-$CC_AKS_CLUSTER_NAME}
RG=${4:-$CC_RESOURCE_GROUP_NAME}
source bin/base.sh


H="np-upgrade \"nodepoolname\" \"--min-count 1 --max-count 5 --enable-cluster-autoscaler\""

empty "$1" "Node pool name" "$H"
empty "$2" "Upgrade Commands" "$H"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPM}']"`

if [ "${E}" != "[]" ]; then
C="az aks nodepool upgrade \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPM} ${UPGRADE_CMDS}"
ok && run-cmd "${C}"
else
info "No cluster ${KS} found in ${RG} "
fi
