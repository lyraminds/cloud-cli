SD_NAME=""
TXT_VALUE=""
DO=${CC_DOMAIN_NAME}
RG=${CC_RESOURCE_GROUP_NAME_DNS}
SUB=${CC_SUBSCRIPTION_DNS}

source bin/base.sh

H="
./dns-txt.sh -n \"sub-domain-name\" -t \"txt value\"
./dns-txt.sh -n \"sub-domain-name\" -t \"txt value\" -d \"domain-name.com\" 
./dns-txt.sh -n \"sub-domain-name\" -t \"txt value\" -d \"\$CC_DOMAIN_NAME\" -g \"\$CC_RESOURCE_GROUP_NAME\" 
"

help "$1" "$H"

while getopts o:d:n:t:g: flag
do
info "az/dns-txt.sh ${flag} ${OPTARG}"
    case "${flag}" in
        d) DO=${OPTARG};;
        n) SD_NAME=${OPTARG};;
        t) TXT_VALUE=${OPTARG};;
        g) RG=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done


empty "$SD_NAME" "SUB DOMAIN NAME" "$H"
empty "$TXT_VALUE" "TXT_VALUE" "$H"
empty "$DO" "DOMAIN NAME" "$H"
empty "$RG" "RESOURCE GROUP NAME" "$H"


E=`az network dns record-set txt list --subscription ${SUB} -g ${RG} -z ${DO} --query "[?name=='${SD_NAME}']"` #TODO SD_NAME OR TXT_VALUE
if [ "${E}" == "[]" ]; then

#TXT_VALUE
C="az network dns record-set txt add-record --subscription ${SUB} -g ${RG} -z ${DO} -n ${SD_NAME} --value \"${TXT_VALUE}\""

ok && run-cmd "${C}"

rlog "az network dns record-set txt remove-record --subscription ${SUB} -g ${RG} -z ${DO} -n ${SD_NAME}"
vlog "az network dns record-set txt show --subscription ${SUB} -g ${RG} -z ${DO} -n ${SD_NAME}"
fi
