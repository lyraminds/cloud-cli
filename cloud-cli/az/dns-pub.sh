
RG=${1:-$CC_RESOURCE_GROUP_NAME}
DO=${2-$CC_DOMAIN_NAME}

source base.sh


rlog "az network dns zone delete -g ${RG} -n ${DO}"

E=`az network dns zone list -g ${RG} --query "[?name=='${DO}']"`
if [ "${E}" == "[]" ]; then
C="az network dns zone create -g ${RG} -n ${DO} --tags ${CC_TAGS}"
ok && run-cmd "${C}" 

fi
vlog "az network dns zone show -g ${RG} -n ${DO}"






# C="az network dns record-set a add-record -g ${RG} -z ${DO} -n www -a $PUB_IP"
# isok && ./run-cmd "${C}" 

# ./print-out "az network dns record-set list -g ${RG} -z ${DO}"
# ./print-out "az network dns record-set ns show -g ${RG} -z ${DO} --name @"
# ./print-out "nslookup www.${DO} ns1-06.azure-dns.com"

