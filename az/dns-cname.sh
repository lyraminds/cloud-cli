SD_NAME=""
CNAME=""
DO=${CC_DOMAIN_NAME}
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H="
./dns-cname.sh -n \"sub-domain-name\" -c \"cname-url.com\"
./dns-cname.sh -n \"sub-domain-name\" -c \"cname-url.com\" -d \"domain-name.com\" 
./dns-cname.sh -n \"sub-domain-name\" -c \"cname-url.com\" -d \"\$CC_DOMAIN_NAME\" -g \"\$CC_RESOURCE_GROUP_NAME\" 
"

help "$1" "$H"

while getopts o:d:n:g:c: flag
do
info "az/dns-cname.sh ${flag} ${OPTARG}"
    case "${flag}" in
        d) DO=${OPTARG};;
        n) SD_NAME=${OPTARG};;
        c) CNAME=${OPTARG};;
        g) RG=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done


empty "$SD_NAME" "SUB DOMAIN NAME" "$H"
empty "$CNAME" "CNAME" "$H"
empty "$DO" "DOMAIN NAME" "$H"
empty "$RG" "RESOURCE GROUP NAME" "$H"



rlog "az network dns record-set cname remove-record -g ${RG} -z ${DO} -n ${SD_NAME} -c ${CNAME}"

E=`az network dns record-set cname list -g ${RG} -z ${DO} --query "[?name=='${SD_NAME}']"` #TODO SD_NAME OR CNAME
if [ "${E}" == "[]" ]; then

#CNAME
C="az network dns record-set cname set-record -g ${RG} -z ${DO} --record-set-name ${SD_NAME} --cname \"${CNAME}\""

ok && run-cmd "${C}"

fi
vlog "az network dns record-set ns show -g ${RG} -z ${DO} --name @"
vlog "az network dns record-set cname show -g ${RG} -z ${DO} -n ${SD_NAME}"






# C="az network dns record-set a add-record -g ${RG} -z ${DO} -n www -a $PUB_IP"
# isok && ./run-cmd "${C}" 

# ./print-out "az network dns record-set list -g ${RG} -z ${DO}"
# ./print-out "az network dns record-set ns show -g ${RG} -z ${DO} --name @"
# ./print-out "nslookup www.${DO} ns1-06.azure-dns.com"

