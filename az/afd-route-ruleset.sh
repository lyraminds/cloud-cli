#!/bin/bash


RSN=""
SD_NAME=""
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H='az/afd-route-ruleset.sh -n "rulesetname" -e "api" '

help "${1}" "${H}"

while getopts n:e: flag
do
info "az/afd-route-ruleset.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) RSN=${OPTARG};;
        e) SD_NAME=${OPTARG};;        
    esac
done

empty "$RG" "RESOURCE GROUP NAME" "$H"
empty "$RSN" "Rule set name" "$H"
empty "$SD_NAME" "Subdomain" "$H"
#--sku {Premium_AzureFrontDoor, Standard_AzureFrontDoor}

E=`az afd rule-set list -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --query "[?name=='${RSN}']"`
if [ "${E}" != "[]" ]; then
if [ "${SD_NAME}" == "." ]; then
SD_NAME=""
fi
SD_NAME=$(fqn ${SD_NAME})-route


C="az afd route update -g ${RG} --endpoint-name "${CC_FRONT_DOOR_ENDPOINT}" --profile-name  "${CC_FRONT_DOOR_PROFILE}" --route-name ${SD_NAME} --rule-sets ${RSN}"
ok && run-cmd "$C"

fi






