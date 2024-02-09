#!/bin/bash
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

E=`az aks list -g ${RG} --query "[?name=='${KS}']"`

if [ "${E}" != "[]" ]; then
E=`az aks show --name ${KS} -g ${RG} --query "[powerState]" -o tsv`

if [ "${E}" == "Stopped" ]; then
C="az aks start --name ${KS} -g ${RG}"
ok && run-cmd "${C}"
ok
else
echo "${KS} is ${E}"
fi




fi




