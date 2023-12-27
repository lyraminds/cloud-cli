
#!/bin/bash

IP_NAME=""
DU=${CC_REDUNDANCY}
RG=${CC_RESOURCE_GROUP_NAME}
# Sample Node count 1, 3, 5
OPTIONS="--sku Standard"

source bin/base.sh

H="
./ip-pub.sh -i \"\$CC_DNS_IP_NAME\"
./ip-pub.sh -i \"\$CC_DNS_IP_NAME\" -r \"\$CC_REDUNDANCY\" -g \"\$CC_RESOURCE_GROUP_NAME\"
"
help "$1" "$H"

while getopts i:g:r:o: flag
do
info "az/ip-pub.sh ${flag} ${OPTARG}"
    case "${flag}" in
        i) IP_NAME=${OPTARG};;
        g) RG=${OPTARG};;
        r) DU=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done

empty "$IP_NAME" "IP NAME" "$H"
empty "$DU" "REDUNDANCY" "$H"
empty "$RG" "RESOURCE_GROUP_NAME" "$H"


Z=''
if [ "${DU}" != "0" ]; then
Z="--zone ${DU}"
fi

E=`az network public-ip list -g ${RG} --query "[?name=='${IP_NAME}']"`

if [ "${E}" == "[]" ]; then
C="az network public-ip create \
 -n ${IP_NAME} \
 -g ${RG} \
 --allocation-method static ${Z} \
 --tags ${CC_TAGS} ${OPTIONS}"
#  --zone 1 use update\
ok && run-cmd "$C"

rlog "az network public-ip delete -g ${RG} -n ${IP_NAME}"
vlog "az network public-ip list -g ${RG} --query "[?name==\'${IP_NAME}\']""

fi



# az rest --method get --uri '/subscriptions/${CC_SUBSCRIPTION}/locations?api-version=2022-12-01' --query name --output tsv





