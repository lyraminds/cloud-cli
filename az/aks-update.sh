#!/bin/bash

UPGRADE_CMDS=""
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
source bin/base.sh


H="
./az/aks-update.sh -o \"--node-count 1\"
./az/aks-update.sh -o \"--node-count 1\" -c \"clustername\"
"

help "${1}" "${H}"

while getopts o:p:c: flag
do
info "az/aks-update.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) UPGRADE_CMDS=${OPTARG};;
        c) KS=${OPTARG};;
    esac
done

empty "$RG" "RESOURCE GROUP NAME" "$H"
empty "$UPGRADE_CMDS" "Upgrade commands" "$H"
empty "$KS" "Cluster Name" "$H"


E=`az aks list -g ${RG} --query "[?name=='${KS}']"`
if [ "${E}" != "[]" ]; then
C="az aks update \
    -g ${RG} \
    -n ${KS} ${UPGRADE_CMDS}"
ok && run-cmd "${C}"
else
info "No cluster ${KS} found in ${RG} "
fi
