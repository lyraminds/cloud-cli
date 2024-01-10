#!/bin/bash

NPN=$1
KS=${2:-$CC_AKS_CLUSTER_NAME}
RG=${3:-$CC_RESOURCE_GROUP_NAME}
source bin/base.sh


H="np-upgrade-image \"nodepoolname\""

empty "$1" "Node pool name" "$H"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPN}']"`
if [ "${E}" == "[]" ]; then

LV=`az aks nodepool get-upgrades \
	--name ${KS} \
	-g ${RG} \
	--query "[latestNodeImageVersion]"`

info ${LV}

CV=`az aks nodepool show \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPN} \
    --query nodeImageVersion`

info ${CV}

if [ "${CV}" != "${LV}" ]; then

 read -sp "###################### IMPORTANT WARNING: #########################3
  Current Image Version ${CV} on Nodepool ${NPN} on cluster ${KS} under resource group [${RG}] in ${CC_REGION}
  Latest Image Version ${LV}  on Nodepool ${NPN} on cluster ${KS}
  Are you sure to upgrade your nodepool image (y/n): " YN && echo && if [ "${YN}" == "y" ]; then run-cmd "az aks nodepool upgrade \
 -g ${RG} \
 --cluster-name ${KS} \
 --name ${NPN} \
 --node-image-only"; fi
else
info "No Change in Current Image Version ${CV} on Nodepool ${NPN} on cluster ${KS} under resource group [${RG}] in ${CC_REGION}"
fi
fi