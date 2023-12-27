
DO=${CC_DOMAIN_NAME}
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H="
./dns-zone.sh -d \"domain-name.com\"
./dns-zone.sh -d \"\$CC_DOMAIN_NAME\" -g \"\$CC_RESOURCE_GROUP_NAME\" 
"

help "$1" "$H"

while getopts o:d:g: flag
do
info "az/dns-zone.sh ${flag} ${OPTARG}"
    case "${flag}" in
        d) DO=${OPTARG};;
        g) RG=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done

empty "$DO" "DOMAIN NAME" "$H"
empty "$RG" "RESOURCE GROUP NAME" "$H"

E=`az network dns zone list -g ${RG} --query "[?name=='${DO}']"`
if [ "${E}" == "[]" ]; then
C="az network dns zone create -g ${RG} -n ${DO} --tags ${CC_TAGS}"
ok && run-cmd "${C}" 

rlog "az network dns zone delete -g ${RG} -n ${DO}"
vlog "az network dns zone show -g ${RG} -n ${DO}"
fi