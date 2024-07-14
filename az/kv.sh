#!/bin/bash

KVN=${CC_KEYVAULT_NAME}
SNET=${CC_SUBNET_NAME}
VNET=${CC_VNET_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
KS=${CC_AKS_CLUSTER_NAME}
OPTIONS="--enable-rbac-authorization false"

source bin/base.sh

SNET_ID=`az/snet-get.sh "${CC_SUBNET_NAME}"`

H='
az/kv.sh -n "keyvaultname" -o "az cli options" -c "aks cluster name" -d "false|true delete and purge keyvault"
az/kv.sh -n "keyvaultname" -o "--enable-rbac-authorization false" -c "${CC_AKS_CLUSTER_NAME}" -p "false"
'

help "$1" "$H"

while getopts o:n:c: flag
do
info "az/kv.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) OPTIONS=${OPTARG};;
        n) KVN=${OPTARG};;
        c) KS=${OPTARG};;
    esac
done

empty "$KVN" "keyvault Name" "$H"


E=`az keyvault list -g ${RG} --query "[?name=='${KVN}']"`
if [ "${E}" == "[]" ]; then

run-cmd "az provider register -n Microsoft.KeyVault"

if [ ! -z "$KS" ]; then
# echo "az aks addon list --resource-group ${RG} --query \"[?name=='${KS}']\""

E=`az aks addon list --resource-group ${RG} --name=${KS} --query "[?name=='azure-keyvault-secrets-provider'].enabled" -o tsv`

if [ "${E}" != "true" ]; then
run-cmd "az aks enable-addons --addons azure-keyvault-secrets-provider --name ${KS} --resource-group ${RG}"
C="kubectl get pods -n kube-system -l 'app in (secrets-store-csi-driver, secrets-store-provider-azure)'"
run-cmd "${C}"
vlog "${C}"
fi
# run-cmd "${C}"
fi

C="az keyvault create \
 -g ${RG} \
 --location ${CC_REGION} \
 --name ${KVN} \
 --resource-group "${RG}" \
 --tags \"${CC_TAGS}\" ${OPTIONS} "

ok && run-cmd "$C"

KV_APP="${CC_KV_APP}"
if [ "${E}" != "${KVN}-app" ]; then
KV_APP="${KVN}-app"
fi

E=`az ad sp list --display-name ${KV_APP}`
if [ "${KV_APP}" == "[]" ]; then


KV_CLIENT_SECRET=`az ad sp create-for-rbac --name ${KV_APP} --role Contributor --query 'password' -o tsv --scopes /subscriptions/${CC_SUBSCRIPTION}`
audit "az ad sp create-for-rbac --name ${KV_APP} --role Contributor --query 'password' -o tsv --scopes /subscriptions/${CC_SUBSCRIPTION}"


KV_CLIENT_ID=`az ad sp list --display-name ${KV_APP} --query '[0].appId' -o tsv`
KV_TENANT_ID=`az ad sp list --display-name ${KV_APP} --query '[0].appOwnerOrganizationId' -o tsv` 

###storing locally for other references
SECRET="${KVN}-secret"
secret-file "${SECRET}"
secret-add "${KV_APP}" "kv-app-name"  
secret-add "${KV_CLIENT_SECRET}" "kv-app-password" 
secret-add "${KV_CLIENT_ID}" "kv-app-id" 
secret-add "${KV_TENANT_ID}" "kv-app-tenant-id" 
secret-clear

run-cmd "az keyvault set-policy -n ${KVN} --secret-permissions get --spn ${KV_CLIENT_ID}"

run-cmd "kubectl create secret generic secrets-store-creds --from-literal clientid=${KV_CLIENT_ID} --from-literal clientsecret=${KV_CLIENT_SECRET} --namespace kube-system"

az aks show -g ${RG} -n ${KS} --query "identity"

az aks show -g ${RG} -n ${KS} --query "servicePrincipalProfile"

az aks show -g ${RG} -n ${KS} --query "addonProfiles.azureKeyvaultSecretsProvider.identity.clientId" -o tsv

fi


rlog "az keyvault delete -g ${RG} -n ${KVN}"
rlog "az keyvault purge -n ${KVN}"
vlog "az aks show -g ${RG} -n ${KVN}"



fi


# --network-acls-ips
# --network-acls "{\"ip\": [\"1.2.3.4\", \"2.3.4.0/24\"], \"vnet\": [\"$CC_VNET_NAME/$CC_SUBNET_NAME\", \"${SNET_ID}\"]}"