source zlink.sh

export CC_MODE=live

#Destroy the whole infrastructure
source az/rg-destroy.sh

source az/cli.sh
source az/init.sh
source az/rg.sh
source az/nsg.sh
source az/vnet.sh

#source az/snet-get.sh "${CC_SUBNET_NAME}"
#source az/dns-zone.sh
#source az/ip-pub.sh "$CC_DNS_IP_NAME"
#source az/ip-get.sh "$CC_DNS_IP_NAME"

source az/acr.sh
# optional, make acr replica in a different region for premium sku other than the current region
#source az/acr-replica.sh "eastus"

#source az/ip-pub.sh "$CC_AKS_IP_NAME"

## AKS ###############
source az/init-aks.sh
source az/aks.sh
source az/aks-np.sh -n "nptest2" -m "Standard_DS2_v2" -d "40"

IP_NAME=$CC_AKS_IP_NAME

source az/ip-pub-aks.sh -n "$IP_NAME"
source az/afd-add.sh "$IP_NAME" "testurl"



#just to see the running node pools
source az/aks-use.sh
