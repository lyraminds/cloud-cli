## Azure AKS Infrastructure Setup – Documentation

This guide documents the step-by-step setup and teardown of Azure infrastructure for deploying an AKS cluster with multiple node pools across subnets, ACR, DNS setup, and more.


**Create install-aks.sh** 

Master file for Azure AKS creation

```sh
source zlink.sh

export CC_MODE=live

#### Destroy the whole infrastructure
# source az/rg-destroy.sh
# source az/aks-stop.sh
# source az/aks-start.sh
# exit

#### Install Azure cli and initialize
# source az/cli.sh
# source az/init.sh


#### Create resource group, network security group and vnet and subnet
# source az/rg.sh
# source az/nsg.sh
# source az/vnet.sh


#### Create azure container registry
# source az/acr.sh
#### optional, for DR make acr replica in a different region other than your current region (premium sku)
#source az/acr-replica.sh "eastus"


#### Install kubernetes, create aks cluster and node pools
# source az/init-aks.sh
# source az/aks.sh
# ./az/aks.sh -p "agentpool" -o "--node-count 2 --min-count 2 --max-count 6 --max-pods 250 --enable-cluster-autoscaler --load-balancer-sku Standard"
# ./az/aks-update.sh -o "--tags ${CC_TAGS}"
# ./az/aks-np-update.sh -p "agentpool" -o "--min-count 1 --max-count 4 --update-cluster-autoscaler"
# source az/aks-np.sh -p "nptest1" -m "Standard_DS2_v2" -d "30"

### Create a nodepool under a different subnet

## Important Notes:
##    Only User node pools can be assigned to custom subnets. The System node pool must remain in its original subnet.
##    You cannot move a node pool to another subnet after creation.
##    Ensure the subnets do not overlap, and have enough IPs for scale.


#SNET2=$(snet-name "2")
#./az/snet.sh ${SNET2} "10.241.0.0/16"
#source az/aks-np.sh -p "nptest2" -m "Standard_DS2_v2" -d "30" -s ${SNET2}



#### DNS, AKS Public IP, Front Door, and sub domain
# source az/dns-zone.sh
# source az/ip-aks.sh "${CC_EMISSARY_IP_NAME}"
# source az/ip-aks.sh "${CC_ISTIO_IP_NAME}"
# source az/afd-aks.sh


# #### View the running node pools
# source az/aks-use.sh

## Create key vault
## source az/kv.sh

### Link your acr with aks, Write permission is required
# source az/aks-acr-link.sh 

```



## Reference

[AKS Cluster](/doc/aks-cluster.md)

