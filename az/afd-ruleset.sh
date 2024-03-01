#!/bin/bash


RSN=""
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H='az/afd-ruleset.sh -n "rulesetname" '

help "${1}" "${H}"

while getopts n: flag
do
info "az/afd-ruleset.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) RSN=${OPTARG};;
    esac
done

empty "$RG" "RESOURCE GROUP NAME" "$H"
empty "$RSN" "Rule set name" "$H"

#--sku {Premium_AzureFrontDoor, Standard_AzureFrontDoor}

E=`az afd rule-set list -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --query "[?name=='${RSN}']"`
if [ "${E}" == "[]" ]; then

C="az afd rule-set create -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} -n ${RSN}"
ok && run-cmd "$C"

rlog "az afd  rule-set delete -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} -n ${RSN}"
vlog "az afd  rule-set show -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} -n ${RSN}"

fi






