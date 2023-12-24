SD_NAME=""
DO=${CC_DOMAIN_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
OPTIONS="--certificate-type ManagedCertificate"
source bin/base.sh

H="
./afd-domain.sh -n \"sub-domain-name\" -o \"--certificate-type ManagedCertificate\"
./afd-domain.sh -n \"sub-domain-name\" -o \"--certificate-type ManagedCertificate\" -d \"domain-name.com\" 
./afd-domain.sh -n \"sub-domain-name\" -o \"--certificate-type ManagedCertificate\" -g \"\$CC_RESOURCE_GROUP_NAME\" 
"

help "$1" "$H"

while getopts o:d:n:g: flag
do
info "az/afd-domain.sh ${flag} ${OPTARG}"
    case "${flag}" in
        d) DO=${OPTARG};;
        n) SD_NAME=${OPTARG};;
        g) RG=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done


empty "$SD_NAME" "SUB DOMAIN NAME" "$H"
empty "$DO" "DOMAIN NAME" "$H"
empty "$RG" "RESOURCE GROUP NAME" "$H"

DOM="${SD_NAME}.${DO}"

rlog "az afd custom-domain delete -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --custom-domain-name \"${SD_NAME}\""

E=`az afd custom-domain list -g ${RG} --profile-name "${CC_FRONT_DOOR_PROFILE}" --query "[?name=='${SD_NAME}']"`
if [ "${E}" == "[]" ]; then

C="az afd custom-domain create -g \"${RG}\" \
 --custom-domain-name \"${SD_NAME}\" \
 --profile-name \"${CC_FRONT_DOOR_PROFILE}\" \
 --host-name \"${DOM}\" \
 --minimum-tls-version TLS12 ${OPTIONS}"

ok && run-cmd "${C}"

#wait till custom domain is created
C="az afd custom-domain wait -g \"${RG}\" \
 --profile-name \"${CC_FRONT_DOOR_PROFILE}\" \
--custom-domain-name \"${SD_NAME}\" --created"

ok && run-cmd "${C}"

fi

vlog "az afd custom-domain show -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --custom-domain-name \"${SD_NAME}\""


