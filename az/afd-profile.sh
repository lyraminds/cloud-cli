#!/bin/bash

RG=${1:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh

#--sku {Premium_AzureFrontDoor, Standard_AzureFrontDoor}

E=`az afd profile list -g ${RG} --query "[?name=='${CC_FRONT_DOOR_PROFILE}']"`
if [ "${E}" == "[]" ]; then

C="az afd profile create -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --origin-response-timeout-seconds ${CC_ORIGIN_RESPONSE_TIMEOUT} --sku ${CC_FRONT_DOOR_SKU} --tags ${CC_TAGS}"
ok && run-cmd "$C"

rlog "az afd profile delete -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE}"
vlog "az afd profile show -g ${RG} -n ${CC_FRONT_DOOR_PROFILE}"

fi








