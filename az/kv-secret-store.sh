#!/bin/bash

KVN=${CC_KEYVAULT_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
NS=""
STORE_NAME="secrets-store-creds"
source bin/base.sh


H='
az/kv-secret-store.sh -n "secret store name" -s "name space" -k "keyvault name"
az/kv-secret-store.sh -n "secret store name" -s "name space" -k "${KVN}" 
'

help "$1" "$H"


while getopts n:s:k: flag
do
info "az/kv.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) STORE_NAME=${OPTARG};;
        k) KVN=${OPTARG};;
        s) NS=${OPTARG};;
    esac
done

empty "$NS" "namespace" "$H"
empty "$KVN" "Keyvault Name" "$H"
empty "$STORE_NAME" "secret storage name" "$H"


E=`az keyvault list -g ${RG} --query "[?name=='${KVN}']"`
if [ "${E}" != "[]" ]; then

KV_APP="${CC_KV_APP}"
if [ "${E}" != "${KVN}-app" ]; then
KV_APP="${KVN}-app"
fi

E=`az ad sp list --display-name ${KV_APP}`

if [ "${E}" != "[]" ]; then


SECRET="${KVN}-secret"
APP_PASS=`cat ${CC_BASE_SECRET_FOLDER}/${SECRET}/kv-app-password`
APP_ID=`cat ${CC_BASE_SECRET_FOLDER}/${SECRET}/kv-app-id`
./kube/ns.sh "${NS}"


E=$(kubectl get secret -n "${NS}" --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null)
if [[ -z ${E} ]]; then
run-cmd "kubectl create secret generic ${STORE_NAME} --from-literal clientid=${APP_ID} --from-literal clientsecret=${APP_PASS} --namespace ${NS}"
# C="kubectl create namespace ${NS} --dry-run=client -o yaml | kubectl apply -f -"
# run-cmd "${C}" 
# run-sleep "1"
  fi






else
error "App ${KV_APP} not found for key vault ${KVN}"
fi

else
error "key vault not found with name ${KVN}"
fi