#!/bin/bash

KVM=${CC_KEYVAULT_NAME}

source bin/base.sh

SNET_ID=`az/snet-get.sh "${CC_SUBNET_NAME}"`

H="
az/kv.sh -o \"--network-acls-vnets $CC_VNET_NAME/$CC_SUBNET_NAME\"
az/kv.sh -n \"keyvaultname\" -o \"--network-acls-vnets \"$SNET_ID\"\"
"

help "$1" "$H"

while getopts o:n: flag
do
info "az/kv.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) OPTIONS=${OPTARG};;
        n) KVM=${OPTARG};;
    esac
done





empty "$KVM" "keyvault Name" "$H"



rlog "az keyvault delete -g ${RG} -n ${KVM}"
rlog "az keyvault purge -n $KVM"

E=`az keyvault list -g ${RG} --query "[?name=='${KVM}']"`
if [ "${E}" == "[]" ]; then

C="az keyvault create \
 -g ${RG} \
 --location ${CC_REGION} \
 --name ${KVM} \
 --resource-group "${RG}" \
 --tags \"${CC_TAGS}\" ${OPTIONS} "

ok && run-cmd "$C"

fi

vlog "az aks show -g ${RG} -n ${KVM}"
# --network-acls-ips
# --network-acls "{\"ip\": [\"1.2.3.4\", \"2.3.4.0/24\"], \"vnet\": [\"$CC_VNET_NAME/$CC_SUBNET_NAME\", \"${SNET_ID}\"]}"