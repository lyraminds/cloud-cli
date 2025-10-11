#!/bin/bash


RSN=""
SD_NAME=""
RG=${CC_RESOURCE_GROUP_NAME}
OPTIONS=""
source bin/base.sh

H='az/afd-ruleset-rule-action.sh -n "rulesetname" 
-o "--rule-name corsallow --order 2 --action-name "ModifyResponseHeader" --header-action Overwrite --header-name Access-Control-Allow-Origin --header-value "https://domain.com"
 '

help "${1}" "${H}"

while getopts n:o: flag
do
info "az/afd-ruleset-rule-action.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) RSN=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done

empty "$RG" "RESOURCE GROUP NAME" "$H"
empty "$RSN" "Rule set name" "$H"
empty "$OPTIONS" "Options" "$H"
#--sku {Premium_AzureFrontDoor, Standard_AzureFrontDoor}

E=`az afd rule-set list -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --query "[?name=='${RSN}']"`
if [ "${E}" != "[]" ]; then

C="az afd rule action add -g ${RG} --profile-name  ${CC_FRONT_DOOR_PROFILE} --rule-set-name ${RSN} ${OPTIONS}"
ok && run-cmd "$C"

fi






