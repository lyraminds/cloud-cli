

source bin/base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}

USER_NAME=azureuser
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H='
./az/vm-ssh.sh -n "vmname" -u "loginusername" 
./az/vm-ssh.sh -n "vmtest" -u "azureuser"  

'

help "${1}" "${H}"

while getopts n:u: flag
do
info "az/vm-ssh.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) VM_NAME=${OPTARG};;
        u) USER_NAME=${OPTARG};;
    esac
done

empty "$VM_NAME" "VM_NAME" "$H"

# Create resource groups if it does not exist yet
if [ $(az group exists --name "$RG") == 'true' ]; then


E=`az vm list -g ${RG} --query "[?name=='${VM_NAME}']"`
if [ "${E}" != "[]" ]; then

export IP_ADDRESS=$(az vm show --show-details --resource-group $RG --name $VM_NAME --query publicIps --output tsv)
ssh -o StrictHostKeyChecking=no $USER_NAME@$IP_ADDRESS 
else
echo "VM ${VM_NAME} does not exist"
fi
fi







