
IP_NAME=${1}
RG=${2:-$CC_RESOURCE_GROUP_NAME}

source base.sh

empty "$1" "IP NAME" "./ip-pub.sh \"${CC_DNS_IP_NAME}\""

IPEXIST="az network public-ip show --resource-group ${RG} --name ${IP_NAME} --query ipAddress --output tsv"
IP=`${IPEXIST}`
echo "${IP}"