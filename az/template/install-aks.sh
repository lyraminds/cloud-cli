source zlink.sh

export CC_MODE=live

#### Destroy the whole infrastructure
# source az/rg-destroy.sh
# source az/aks-stop.sh
# source az/aks-start.sh


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


### Use default for test or customized for production
### Customize the creation with -o options
### to use 3 availability zone add to options --zones 1 2 3
#./az/aks.sh
## OR
#./az/aks.sh -p "systempool" -m "Standard_D2s_v4" -d "30" -o "--node-count 1 --min-count 1 --max-count 8 --max-pods 250 --enable-cluster-autoscaler --load-balancer-sku Standard --tier standard --zones 1 2 3"

#### DNS, AKS Public IP, Front Door
source az/dns-zone.sh
source az/ip-aks.sh "${CC_EMISSARY_IP_NAME}"
source az/ip-aks.sh "${CC_ISTIO_IP_NAME}"
source az/afd-aks.sh


#### View the running node pools
source az/aks-use.sh


#### Link your acr with aks is required for deployment of apps,
#### You would also need role update permission run this command
source az/aks-acr-link.sh 