source zlink.sh

export CC_MODE=live

#### Destroy the whole infrastructure
# source az/rg-destroy.sh

#### Install Azure cli and initialize
source az/cli.sh
source az/init.sh


#### Create resource group, network security group and vnet and subnet
source az/rg.sh
source az/nsg.sh
source az/vnet.sh


#### Create azure container registry
source az/acr.sh
#### optional, for DR make acr replica in a different region other than your current region (premium sku)
#source az/acr-replica.sh "eastus"


#### Install kubernetes, create aks cluster and node pools
source az/init-aks.sh
source az/aks.sh

# Customize the creation with -o options
# to use specific version add to options --kubernetes-version 1.27.7
# to use 3 availability zone add to options --zones 1 2 3
# ./az/aks.sh -o "--node-count 1 --min-count 1 --max-count 8 --max-pods 250 --enable-cluster-autoscaler --load-balancer-sku Standard --tier standard --zones 1 2 3"


#### DNS, AKS Public IP, Front Door
source az/dns-zone.sh
source az/ip-aks.sh
source az/afd-aks.sh


#### View the running node pools
source az/aks-use.sh
