

IP_NAME=${1}
DU=${2:-$CC_REDUNDANCY}
RG=${3:-$CC_RESOURCE_GROUP_NAME}


source base.sh

empty "$1" "IP NAME" "./ip-pub.sh \"\$CC_DNS_IP_NAME\""
empty "$DU" "REDUNDANCY" "./ip-pub.sh \"\$CC_DNS_IP_NAME\" \"\$CC_REDUNDANCY\""

rlog "az network public-ip delete -g ${RG} -n ${IP_NAME}"
Z=''
if [ "${DU}" != "0" ]; then
Z="--zone ${DU}"
fi

E=`az network public-ip list -g ${RG} --query "[?name=='${IP_NAME}']"`

if [ "${E}" == "[]" ]; then
C="az network public-ip create \
 -n ${IP_NAME} \
 -g ${RG} \
 --sku Standard \
 --allocation-method static ${Z} \
 --tags ${CC_TAGS}"
 echo "$C"
#  --zone 1 use update\
ok && run-cmd "$C"

fi
vlog "az network public-ip list -g ${RG} --query "[?name==\'${IP_NAME}\']""


# az rest --method get --uri '/subscriptions/46107353-1b4b-43d9-bcb5-0542726f5894/locations?api-version=2022-12-01' --query name --output tsv

# IPEXIST="az network public-ip show -g ${RG} -n ${LB} --query ipAddress --output tsv"

# IP=`${IPEXIST}`


# Create resource groups if it does not exist yet
# if [ -z "${IP}" ]; then





# IP=`${IPEXIST}`
# fi

# echo $(( $? + 3 ))



