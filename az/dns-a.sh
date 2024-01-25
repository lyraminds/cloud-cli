SD_NAME=""
ARECORD=""
DO=${CC_DOMAIN_NAME}
RG=${CC_RESOURCE_GROUP_NAME_DNS}
SUB=${CC_SUBSCRIPTION_DNS}
source bin/base.sh

H="
./dns-a.sh -n \"sub-domain-name\" -a \"a-record-ip-or-domain\"
./dns-a.sh -n \"sub-domain-name\" -a \"a-record-ip-or-domain\" -d \"domain-name.com\" 
./dns-a.sh -n \"sub-domain-name\" -a \"a-record-ip-or-domain\" -d \"\$CC_DOMAIN_NAME\" -g \"\$CC_RESOURCE_GROUP_NAME\" 
"

help "$1" "$H"

while getopts o:d:n:g: flag
do
info "az/dns-a.sh ${flag} ${OPTARG}"
    case "${flag}" in
        d) DO=${OPTARG};;
        n) SD_NAME=${OPTARG};;
        a) ARECORD=${OPTARG};;
        g) RG=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done


empty "$SD_NAME" "SUB DOMAIN NAME" "$H"
empty "$ARECORD" "ARECORD" "$H"
empty "$DO" "DOMAIN NAME" "$H"
empty "$RG" "RESOURCE GROUP NAME" "$H"


E=`az network dns record-set a list --subscription ${SUB} -g ${RG} -z ${DO} --query "[?name=='${SD_NAME}']"` #TODO SD_NAME OR ARECORD
if [ "${E}" == "[]" ]; then

#ARECORD
C="az network dns record-set a add-record --subscription ${SUB} -g ${RG} -z ${DO} --record-set-name ${SD_NAME} -a \"${ARECORD}\""

ok && run-cmd "${C}"

rlog "az network dns record-set a remove-record --subscription ${SUB} -g ${RG} -z ${DO} -n ${SD_NAME} -a ${ARECORD}"
vlog "az network dns record-set ns show -g ${RG} --subscription ${SUB} -z ${DO} --name @"
vlog "az network dns record-set a show -g ${RG} --subscription ${SUB}-z ${DO} -n ${SD_NAME}"

fi



