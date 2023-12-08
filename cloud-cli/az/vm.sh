

source base.sh

_RESOURCE_GROUP=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}


# Create resource groups if it does not exist yet
if [ $(az group exists --name "$_RESOURCE_GROUP") == 'false' ]; then
run-cmd "az group create --name $_RESOURCE_GROUP --location $_REGION"

vmname="myVM"
username="azureuser"
az vm create \
    --resource-group $_RESOURCE_GROUP \
    --name $vmname \
    --image Win2022AzureEditionCore \
    --public-ip-sku Standard \
    --admin-username $username 

fi




