

source bin/base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}


USER_NAME=azureuser
IMAGE_NAME="Ubuntu2204"
OPTIONS="--assign-identity --generate-ssh-keys --public-ip-sku Standard"
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H='
./az/vm-linux.sh -n "vmname" -i "image" -u "loginusername" -o "az cli options"
./az/vm-linux.sh -n "vmtest" -i "Ubuntu2204" -u "azureuser"  -o "--assign-identity --generate-ssh-keys --public-ip-sku Standard --data-disk-sizes-gb 20 --size Standard_DS2_v2"

'

help "${1}" "${H}"

while getopts o:n:i:u: flag
do
info "az/vm-linux.sh ${flag} ${OPTARG}"
    case "${flag}" in
        o) OPTIONS=${OPTARG};;
        n) VM_NAME=${OPTARG};;
        i) IMAGE_NAME=${OPTARG};;
        u) USER_NAME=${OPTARG};;
    esac
done

empty "$VM_NAME" "VM_NAME" "$H"

# Create resource groups if it does not exist yet
if [ $(az group exists --name "$RG") == 'false' ]; then
run-cmd "az group create --name $RG --location $_REGION"
fi



E=`az vm list -g ${RG} --query "[?name=='${VM_NAME}']"`
if [ "${E}" == "[]" ]; then

run-cmd "az vm create \
    --resource-group $RG \
    --name ${VM_NAME} \
    --image ${IMAGE_NAME} \
    --admin-username ${USER_NAME} \
    --public-ip-address-dns-name ${VM_NAME}dns ${OPTIONS}"


run-cmd "az vm extension set \
    --publisher Microsoft.Azure.ActiveDirectory \
    --name AADSSHLoginForLinux \
    --resource-group  ${RG} \
    --vm-name $VM_NAME "
 

fi






