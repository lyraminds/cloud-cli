#!/bin/bash

KVN=${CC_KEYVAULT_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
KEY_NAME=""
VAL_NAME=""
source bin/base.sh


H='
az/kv-secret.sh -n "key vault name" -k "kev name" -v "key value"
az/kv-secret.sh -n "${KVN}" -k "mariadb-password" -v "AEDF9fllrssktflop9fv544f30h4t9" 
'

help "$1" "$H"

while getopts n:k:v: flag
do
info "az/kv-secret.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) KVN=${OPTARG};;
        k) KEY_NAME=${OPTARG};;
        v) VAL_NAME=${OPTARG};;        
    esac
done

empty "$KVN" "keyvault Name" "$H"
empty "$KEY_NAME" "keyvault key name is required" "$H"
empty "$VAL_NAME" "keyvault key value is required" "$H"

E=`az keyvault list -g ${RG} --query "[?name=='${KVN}']"`
if [ "${E}" != "[]" ]; then

run-cmd "az keyvault secret set --vault-name \"${KVN}\" --name \"${KEY_NAME}\" --value \"${VAL_NAME}\""

fi

