#!/bin/bash

VMSIZE="Standard_D2s_v4"
DISKSIZE="30"
# Sample Node count 1, 3, 5
OPTIONS="--node-count 1 --min-count 1 --max-count 8 --max-pods 250 --enable-cluster-autoscaler --load-balancer-sku Standard --tier free"
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
SNET=${CC_SUBNET_NAME}
CR=${CC_CONTAINER_REGISTRY}

source bin/base.sh

H="
./az/aks.sh  will use the default spec
./az/aks.sh -m \"Virtual machine size\" -d \"Disk size\" -o \"Options\"
./az/aks.sh -m \"${VMSIZE}\" -d \"${DISKSIZE}\" 
./az/aks.sh -m \"${VMSIZE}\" -d \"${DISKSIZE}\" -o \"$OPTIONS\" -c \"clustername-optional\" -s \"subnet-name\" -r \"container-registry\"

you may override the default configs

export CC_AKS_CONFIG=\"--vm-set-type VirtualMachineScaleSets \\
 --enable-aad --enable-azure-rbac \\
 --nodepool-name ${CC_AKS_SYSTEM_NP} \\
 --service-cidr 10.0.0.0/16 \\
 --dns-service-ip 10.0.0.10 \\
 --enable-managed-identity \\
 --network-plugin azure \\
 --generate-ssh-keys \"

"

help "${1}" "${H}"

while getopts o:s:m:c:d:r: flag
do
info "az/aks.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) OPTIONS=${OPTARG};;
        s) SNET=${OPTARG};;
        m) VMSIZE=${OPTARG};;
        c) KS=${OPTARG};;
        r) CR=${OPTARG};;
        d) DISKSIZE=${OPTARG};;
    esac
done

empty "$RG" "RESOURCE GROUP NAME" "$H"
empty "$VMSIZE" "Virtual Machine" "$H"
empty "$KS" "Cluster Name" "$H"
empty "$DISKSIZE" "Disk Size" "$H"

A=''
#NOTE container registry assignment is disabled due to ownership issue
# https://github.com/Azure/AKS/issues/1517
# https://github.com/Azure/AKS/issues/3530
# instead use token to get access
# if [ ! -z "$CR" -a "$CR" != " " ]; then
# A="--attach-acr $CR"
# fi

KSV=""
if [ ! -z "${CC_KUBERNETES_VERSION}" -a "${CC_KUBERNETES_VERSION}" != " " ]; then
KSV="--kubernetes-version ${CC_KUBERNETES_VERSION}"
fi

E=`az aks list -g ${RG} --query "[?name=='${KS}']"`

if [ "${E}" == "[]" ]; then

SNET_ID=`az/snet-get.sh "${SNET}"`
if [ ! -z "$SNET_ID" -a "$SNET_ID" != " " ]; then
SNET_ID="--vnet-subnet-id $SNET_ID"
fi

C="az aks create -g $RG -n $KS $A -s ${VMSIZE} ${SNET_ID} --tags ${CC_TAGS} ${KSV} --node-osdisk-size ${DISKSIZE} $CC_AKS_CONFIG ${OPTIONS}"
ok && run-cmd "${C}"

#To stop scheduling other np to system pool
./az/aks-np-update.sh -p "${CC_AKS_SYSTEM_NP}" -o "--node-taints CriticalAddonsOnly=true:NoSchedule"


rlog "az aks delete -g ${RG} -n ${KS}"
vlog "az aks get-credentials -g $RG --name $KS --admin"
vlog "az aks show -g ${RG} -n ${KS}"
vlog "#=======Update attach acr===============
ACR_ID=\$(az acr show -n \"${KS}\" -g \"${RG}\" --query id -o tsv) 
az aks update -g \"${RG}\" -n \"${KS}\" --attach-acr $ACR_ID
#============================================="

fi



