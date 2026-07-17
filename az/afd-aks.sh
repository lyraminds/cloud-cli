

RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh
H="
./adf-aks.sh
./adf-aks.sh -g \"\$CC_AKSCC_RESOURCE_GROUP_NAME\" 
"

help "$1" "$H"

while getopts o:i:n:g: flag
do
info "az/adf-aks.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) OPTIONS=${OPTARG};;
        g) RG=${OPTARG};;
    esac
done

echo "===================== ${CC_ENABLE_AFD_DOMAIN} ==========================="

empty "$RG" "Resource group" "${H}"
if [ "${CC_ENABLE_AFD_DOMAIN}" = "true" ]; then

echo "===================== ${CC_ENABLE_AFD_DOMAIN} ==========================="

source az/afd-profile.sh ${RG}
source az/afd-endpoint.sh ${RG}

fi
