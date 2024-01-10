#!/bin/bash

NPN=""
UPGRADE_CMDS=""
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
source bin/base.sh


H="az/aks-np-update.sh -p \"nodepoolname\" -o \"--min-count 1 --max-count 5 --enable-cluster-autoscaler\""

help "${1}" "${H}"

while getopts o:p:c: flag
do
info "az/aks-np-update.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) UPGRADE_CMDS=${OPTARG};;
        p) NPN=${OPTARG};;
        c) KS=${OPTARG};;
    esac
done

empty "$RG" "RESOURCE GROUP NAME" "$H"
empty "$UPGRADE_CMDS" "Upgrade commands" "$H"
empty "$KS" "Cluster Name" "$H"
empty "$NPN" "Node pool name" "$H"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPN}']"`
if [ "${E}" != "[]" ]; then
C="az aks nodepool update \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPN} ${UPGRADE_CMDS}"
ok && run-cmd "${C}"
else
info "No cluster ${KS} found in ${RG} "
fi
