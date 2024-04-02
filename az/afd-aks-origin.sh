SD_NAME=""
IP_NAME=${CC_EMISSARY_IP_NAME}
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
AFD_PRIORITY=1
DO=${CC_DOMAIN_NAME}

source bin/base.sh

H="
./adf-aks-origin.sh -n \"sub-domain\" 
./adf-aks-origin.sh -n \"sub-domain\" -d \"domain-name.com\" -i \"ip-name\"
./adf-aks-origin.sh -n \"mysubdomain\" -d \"domain-name\" -i \"\$CC_EMISSARY_IP_NAME\"
"

help "$1" "$H"

while getopts o:i:n:g:d: flag
do
info "az/adf-aks-origin.sh ${flag} ${OPTARG}"
    case "${flag}" in
        d) DO=${OPTARG};;
        i) IP_NAME=${OPTARG};;
        n) SD_NAME=${OPTARG};;
        g) RG=${OPTARG};;
        o) OPTIONS=${OPTARG};;
    esac
done


empty "$SD_NAME" "SUB DOMAIN NAME" "$H"
empty "$DO" "DOMAIN NAME" "$H"
empty "$RG" "RESOURCE GROUP NAME" "$H"

SDN=${SD_NAME}
OG="${SDN}-group"
OR="${SDN}-route"
ON="${SDN}-orign"
DOM="${SDN}.${DO}"

E=`az afd profile list -g ${RG} --query "[?name=='${CC_FRONT_DOOR_PROFILE}']"`
if [ "${E}" != "[]" ]; then

export CC_AKS_RESOURCE_GROUP_NAME=`az aks show --query nodeResourceGroup --name $KS --resource-group $RG --output tsv`
MYIP=`az network public-ip show --resource-group ${CC_AKS_RESOURCE_GROUP_NAME} --name ${IP_NAME} --query ipAddress --output tsv`
empty "$MYIP" "ip under aks resource group ${CC_AKS_RESOURCE_GROUP_NAME}"




E=`az afd origin-group list -g ${RG} --profile-name "${CC_FRONT_DOOR_PROFILE}" --query "[?name=='${OG}']"`
if [ "${E}" == "[]" ]; then

C="az afd origin-group create -g ${RG} --origin-group-name \"${OG}\" \
  --profile-name \"${CC_FRONT_DOOR_PROFILE}\" \
  --probe-request-type HEAD --probe-protocol Http \
  --probe-interval-in-seconds 120 \
  --probe-path \"/\" \
  --sample-size 4 \
  --successful-samples-required 3 \
  --additional-latency-in-milliseconds 50"

ok && run-cmd "${C}"

rlog "az afd origin-group delete -g ${RG} --origin-group-name \"${OG}\" --profile-name \"${CC_FRONT_DOOR_PROFILE}\""
vlog "az afd origin-group list -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --query \"[?name=='${OG}']\""
vlog "az afd origin-group show -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --origin-group-name \"${OG}\""
fi


E=`az afd origin list -g ${RG} --profile-name "${CC_FRONT_DOOR_PROFILE}" --origin-group-name "${OG}" --query "[?name=='${ON}']"`
if [ "${E}" == "[]" ]; then

# C="az afd origin show --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --origin-group-name ${OG} --origin-name ${ON} --resource-group \"${RG}\" --query hostName"

C="az afd origin create -g \"${RG}\" \
  --host-name \"${MYIP}\" \
  --profile-name \"${CC_FRONT_DOOR_PROFILE}\" \
  --origin-group-name ${OG} \
  --origin-name ${ON} \
  --origin-host-header \"${DOM}\" \
  --priority ${AFD_PRIORITY} --weight 500 --enabled-state Enabled --http-port 80 --https-port 443"

ok && run-cmd "${C}"

vlog "az afd origin delete -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --origin-group-name \"${OG}\" --origin-name ${ON}"
vlog "az afd origin show -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --origin-group-name \"${OG}\" --origin-name ${ON}"
vlog "az afd origin list -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --origin-group-name \"${OG}\""

# else

# C="az afd origin update -g \"${RG}\" \
# --host-name \"${MYIP}\" \
# --profile-name \"${CC_FRONT_DOOR_PROFILE}\" \
# --origin-group-name ${OG} \
# --origin-name ${ON} \
# --origin-host-header \"${DOM}\" \
# --priority ${AFD_PRIORITY} "

# ok && run-cmd "${C}"



fi


_CNAME=`az afd endpoint show -g ${RG} --profile-name "${CC_FRONT_DOOR_PROFILE}" --endpoint-name "${CC_FRONT_DOOR_ENDPOINT}" --query hostName`
#_CNAME="${CC_FRONT_DOOR_ENDPOINT}.z01.azurefd.net"

#CNAME
ok && ./az/dns-cname.sh -n "${SD_NAME}" -c "${_CNAME}"
ok && ./az/afd-domain.sh -n "${SD_NAME}"


_TOKEN=`az afd custom-domain show -g "${RG}" --profile-name "${CC_FRONT_DOOR_PROFILE}" --custom-domain-name "${SD_NAME}" --query validationProperties.validationToken`
ok && ./az/dns-txt.sh -n "_dnsauth.${SD_NAME}" -t "${_TOKEN}"


E=`az afd route list -g ${RG} --profile-name "${CC_FRONT_DOOR_PROFILE}" --endpoint-name "${CC_FRONT_DOOR_ENDPOINT}" --query "[?name=='${OR}']"`
if [ "${E}" == "[]" ]; then

C="az afd route create -g \"${RG}\" \
  --custom-domains \"${SD_NAME}\" \
  --endpoint-name \"${CC_FRONT_DOOR_ENDPOINT}\" \
  --profile-name \"${CC_FRONT_DOOR_PROFILE}\" \
  --route-name \"${OR}\" \
  --origin-group \"${OG}\" \
  --https-redirect Enabled --supported-protocols Http Https --link-to-default-domain Disabled --forwarding-protocol HttpOnly"
ok && run-cmd "${C}"

rlog "az afd route delete -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --endpoint-name \"${CC_FRONT_DOOR_ENDPOINT}\" --route-name \"${OR}\""
vlog "az afd route list -g ${RG} --profile-name \"${CC_FRONT_DOOR_PROFILE}\" --endpoint-name \"${CC_FRONT_DOOR_ENDPOINT}\" --query \"[?name=='${OR}']\""

fi

else
echo "No front door skipping ${DOM}"
fi
#   --private-link-resource /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group/providers/Microsoft.Storage/storageAccounts/plstest 
#   --private-link-location EastUS 
#   --private-link-request-message 'Please approve this request' --private-link-sub-resource table




