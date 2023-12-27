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
# source az/aks-np.sh -n "nptest1" -m "Standard_DS2_v2" -d "30"
# source az/aks-np.sh -n "nptest2" -m "Standard_DS2_v2" -d "30"


#### DNS, AKS Public IP, Front Door, and sub domain
source az/dns-zone.sh
source az/ip-aks.sh
source az/afd-aks.sh

# source az/afd-aks-origin.sh -n "subtest1"
# source az/afd-aks-origin.sh -n "subtest2"


#### View the running node pools
source az/aks-use.sh
