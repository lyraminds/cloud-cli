#!/bin/bash
source cloud-cli/conf/default-azure.env
source accounts/private-azure.env
source cloud-cli/init.sh

export CC_MODE=script

./az/cli.sh
./az/init.sh

./az/rg.sh
./az/nsg.sh
./az/vnet.sh

# ./az/snet-get.sh "${CC_SUBNET_NAME}"
# ./az/dns-pub.sh
# ./az/ip-pub.sh "$CC_DNS_IP_NAME"
# ./az/ip-get.sh "$CC_DNS_IP_NAME"

./az/acr.sh
# optional, make acr replica in a different region for premium sku other than the current region
# ./az/acr-replica.sh "eastus"

# ./az/ip-pub.sh "$CC_AKS_IP_NAME"

./az/init-aks.sh
./az/aks.sh
./az/aks-np.sh 

#just to see the running node pools
./az/aks-use.sh







