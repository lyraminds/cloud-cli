
IP_NAME=${1:-$CC_EMISSARY_IP_NAME}
DU=${CC_REDUNDANCY}
RG=${CC_RESOURCE_GROUP_NAME}
KS=${CC_AKS_CLUSTER_NAME}
# Sample Node count 1, 3, 5
OPTIONS="--sku Standard"

source bin/base.sh

H="
./ip-aks.sh -i \"\$CC_DNS_IP_NAME\"
./ip-aks.sh -i \"\$CC_DNS_IP_NAME\" -r \"\$CC_REDUNDANCY\" -g \"\$CC_RESOURCE_GROUP_NAME\" -o \"--sku Standard\"
"

help "$1" "$H"

while getopts o:i:r:g: flag
do
info "az/ip-aks.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) OPTIONS=${OPTARG};;
        i) IP_NAME=${OPTARG};;
        r) DU=${OPTARG};;
        g) RG=${OPTARG};;
    esac
done

empty "$IP_NAME" "IP NAME" "$H"
empty "$DU" "REDUNDANCY" "$H"
empty "$RG" "RESOURCE GROUP NAME" "$H"
empty "$KS" "AKS CLUSTER NAME" "$H"

export CC_AKS_RESOURCE_GROUP_NAME=`az aks show --query nodeResourceGroup --name $KS --resource-group $RG --output tsv`

./az/ip-pub.sh -i ${IP_NAME} -g ${CC_AKS_RESOURCE_GROUP_NAME} -r ${DU} -o "${OPTIONS}"

