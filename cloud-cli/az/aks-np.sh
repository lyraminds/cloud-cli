#!/bin/bash

NPM=$1
VMSIZE=${2:-Standard_DS2_v2}
KS=${3:-$CC_AKS_CLUSTER_NAME}
RG=${4:-$CC_RESOURCE_GROUP_NAME}

source base.sh

H="
./az/aks-np.sh \"nodepoolname\" \"Standard_DS2_v2\"
./az/aks-np.sh \"highmemory|highcpu|gpu|balanced|anyname\" \"Standard_DS2_v2\"

List all available vm sizes in the ${CC_REGION} region which support availability zone.

az vm list-skus -l ${CC_REGION} --zone -o table

az vm list-skus -l ${CC_REGION} --zone --size Standard_D4

https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
"

empty "$1" "NODE POOL NAME" "$H"


rlog "az aks nodepool delete -g ${RG} --cluster-name ${KS} -n ${NPM}"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPM}']"`
if [ "${E}" == "[]" ]; then

C="az aks nodepool add \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPM} \
    --node-taints ${CC_NODE_POOL_TAINT_TYPE}=${NPM}:${CC_NODE_POOL_TAINT_EFFECT} \
    --labels join=${NPM} \
    --node-vm-size ${VMSIZE} ${CC_NODE_POOL_CONFIG} "

ok && run-cmd "$C"

fi



vlog "az aks nodepool show -g ${RG} --cluster-name ${KS} -n ${NPM}"



UV=`az aks get-upgrades \
	--name ${KS} \
	-g ${RG} \
	--query "[controlPlaneProfile][].upgrades[].kubernetesVersion"`


CV=`az aks get-upgrades \
	--name ${KS} \
	-g ${RG} \
	--query "[controlPlaneProfile][].kubernetesVersion"`


vlog "

# node pool upgrade auto scale ====================
az aks nodepool upgrade \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPM} \
    --min-count 1 --max-count 6 --update-cluster-autoscaler \
    --wait

# node view kubernetes upgrade version==============

az aks get-upgrades \
	--name ${KS} \
	-g ${RG} \
	--output table 


# node pool upgrade kubernetes version =============
# Current version is ${CV}
# Upgrades Available ${UV}

az aks nodepool upgrade \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPM} \
    --kubernetes-version ${UV} \
    --wait

"

