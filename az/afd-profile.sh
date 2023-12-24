#!/bin/bash

RG=${1:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh

#--sku {Premium_AzureFrontDoor, Standard_AzureFrontDoor}

rlog "az afd profile delete -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE}"

E=`az afd profile list -g ${RG} --query "[?name=='${CC_FRONT_DOOR_PROFILE}']"`
if [ "${E}" == "[]" ]; then

C="az afd profile create -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --sku ${CC_FRONT_DOOR_SKU} --tags ${CC_TAGS}"
ok && run-cmd "$C"

fi

vlog "az afd profile show -g ${RG} -n ${CC_FRONT_DOOR_PROFILE}"






