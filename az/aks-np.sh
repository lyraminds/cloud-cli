#!/bin/bash
VMSIZE="Standard_DS2_v2"
DISKSIZE="30"
# Sample Node count 1, 3, 5
OPTIONS="--node-count 1 --min-count 1 --max-count 8  --enable-cluster-autoscaler"
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H="
./az/aks-np.sh -p \"nodepoolname\" -m \"Virtual machine size\" -d \"Disk size\" 
./az/aks-np.sh -p \"nodepoolname\" -m \"Standard_DS2_v2\" -d "30" 
./az/aks-np.sh -p \"highmemory|highcpu|gpu|balanced|anyname\" -m \"Standard_DS2_v2\" -d \"30\" -o \"$OPTIONS\"

List all available vm sizes in the ${CC_REGION} region which support availability zone.

az vm list-skus -l ${CC_REGION} --zone -o table

az vm list-skus -l ${CC_REGION} --zone --size Standard_D4

https://learn.microsoft.com/en-us/azure/virtual-machines/sizes

"

help "${1}" "${H}"

while getopts o:p:m:c:d: flag
do
info "az/aks-np.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) OPTIONS=${OPTARG};;
        p) NPN=${OPTARG};;
        m) VMSIZE=${OPTARG};;
        c) KS=${OPTARG};;
        d) DISKSIZE=${OPTARG};;
    esac
done

empty "$NPN" "NODE POOL NAME" "$H"
empty "$VMSIZE" "NODE POOL NAME" "$H"
empty "$DISKSIZE" "Disk Size" "$H"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPN}']"`
if [ "${E}" == "[]" ]; then

C="az aks nodepool add \
    -g ${RG} \
    --cluster-name ${KS} \
    --name ${NPN} \
    # --node-taints ${CC_NODE_POOL_TAINT_TYPE}=${NPN}:${CC_NODE_POOL_TAINT_EFFECT} \
    # --labels join=${NPN} \
    --node-vm-size ${VMSIZE} \
    --node-osdisk-size ${DISKSIZE} \
    --tags ${CC_TAGS} ${OPTIONS} "

if [[ "$OPTIONS" != *"mode System"* ]]; then
C="${C} --node-taints ${CC_NODE_POOL_TAINT_TYPE}=${NPN}:${CC_NODE_POOL_TAINT_EFFECT} --labels join=${NPN}"
fi   

ok && run-cmd "$C"

rlog "az aks nodepool delete -g ${RG} --cluster-name ${KS} -n ${NPN}"
vlog "az aks nodepool show -g ${RG} --cluster-name ${KS} -n ${NPN}"
vlog "az aks nodepool list -g $RG --cluster-name ${KS} -o table"
fi







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
    --name ${NPN} \
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
    --name ${NPN} \
    --kubernetes-version ${UV} \
    --wait

"

