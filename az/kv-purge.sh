#!/bin/bash

KVN=${CC_KEYVAULT_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
KV_PURGE="false"
source bin/base.sh


H='
az/kv.sh -n "keyvaultname" -o "az cli options" -c "aks cluster name" -d "false|true delete and purge keyvault"
az/kv.sh -n "keyvaultname" -o "--enable-rbac-authorization false" -c "${CC_AKS_CLUSTER_NAME}" -d "false"
'

help "$1" "$H"

while getopts n:d: flag
do
info "az/kv.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) KVN=${OPTARG};;
        d) KV_PURGE=${OPTARG};;
    esac
done

empty "$KVN" "keyvault Name" "$H"


E=`az keyvault list -g ${RG} --query "[?name=='${KVN}']"`
if [ "${E}" != "[]" ]; then

if [ "${KV_PURGE}" == "true" ]; then
 
echo "
###################### IMPORTANT WARNING: #########################
This will wipe out your key vault [${KVN}] under resource group [${RG}]
"
read -p "Are you sure to delete your key vault(y/n):" YN

#Print output based on the input

if [ "$YN" == "y" ]; then
run-cmd "az keyvault delete --name ${KVN}  --resource-group ${RG}"
run-cmd "az keyvault purge --name ${KVN}"
elif [ "$YN" == "n" ]; then
echo "You choose to cancel"
else
echo "Invalid option use y or n"
fi

fi


fi


# --network-acls-ips
# --network-acls "{\"ip\": [\"1.2.3.4\", \"2.3.4.0/24\"], \"vnet\": [\"$CC_VNET_NAME/$CC_SUBNET_NAME\", \"${SNET_ID}\"]}"