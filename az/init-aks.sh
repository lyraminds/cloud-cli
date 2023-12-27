
KS=${1:-$CC_AKS_CLUSTER_NAME}
RG=${2:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh


E=`az provider list --query "[?namespace=='Microsoft.OperationsManagement'].resourceTypes[].resourceType"`
if [ "${E}" == "[]" ]; then
ok && az provider register --namespace Microsoft.OperationsManagement
fi

E=`az provider list --query "[?namespace=='Microsoft.OperationalInsights'].resourceTypes[].resourceType"`
if [ "${E}" == "[]" ]; then
ok && az provider register --namespace Microsoft.OperationalInsights
fi

if [ $(installed "kubectl") == "false" ]; then
echo "sudo az aks install-cli"
sudo az aks install-cli

kubectl version
fi


