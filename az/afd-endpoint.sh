#!/bin/bash

RG=${1:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh


E=`az afd endpoint list -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --query "[?name=='${CC_FRONT_DOOR_ENDPOINT}']"`
if [ "${E}" == "[]" ]; then

C="az afd endpoint create -g ${RG} --endpoint-name ${CC_FRONT_DOOR_ENDPOINT} --profile-name ${CC_FRONT_DOOR_PROFILE} --enabled-state Enabled --tags ${CC_TAGS}"
ok && run-cmd "$C"

rlog "az afd endpoint delete -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --endpoint-name ${CC_FRONT_DOOR_ENDPOINT} "
vlog "az afd endpoint show -g ${RG} --profile-name ${CC_FRONT_DOOR_PROFILE} --endpoint-name ${CC_FRONT_DOOR_ENDPOINT}"
vlog "#cname"
vlog "az afd endpoint show -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --endpoint-name "${CC_FRONT_DOOR_ENDPOINT}" --query hostName"

fi

