## Azure AKS Infrastructure Setup – Documentation

This guide documents the step-by-step setup and teardown of Azure infrastructure for deploying an AKS cluster with multiple node pools across subnets, ACR, DNS setup, and more.

📦 Project Structure

az/
├── cli.sh                # Install Azure CLI
├── init.sh               # Azure CLI login and defaults
├── rg.sh                 # Create Resource Group
├── nsg.sh                # Create Network Security Group
├── vnet.sh               # Create Virtual Network and Subnets
├── snet.sh               # Create a new Subnets
├── snet-get.sh           # Print the subnet id
├── acr.sh                # Create Azure Container Registry
├── acr-replica.sh        # Create ACR Geo-replica (Premium SKU only)
├── init-aks.sh           # Common AKS config vars and checks
├── aks.sh                # Create AKS cluster
├── aks-update.sh         # Update tags or properties on AKS
├── aks-np.sh             # Add new node pools
├── aks-np-update.sh      # Update existing node pools
├── aks-use.sh            # View AKS node pool status
├── dns-zone.sh           # DNS zone setup
├── ip-aks.sh             # Reserve public IPs for AKS
├── afd-aks.sh            # Azure Front Door configuration
├── kv.sh                 # Create or use Key Vault
├── aks-acr-link.sh       # Link ACR to AKS
├── aks-start.sh          # Resume AKS cluster
├── aks-stop.sh           # Stop AKS cluster (for cost savings)
├── rg-destroy.sh         # Delete entire resource group


🚀 Setup Instructions
1. Initialize Azure CLI & Login

source az/cli.sh       # Install Azure CLI (if not already)
source az/init.sh      # Login and set default subscription


2. Create Core Infrastructure

source az/rg.sh        # Create resource group
source az/nsg.sh       # Create Network Security Group
source az/vnet.sh      # Create VNet and Subnets


3. Setup Azure Container Registry

source az/acr.sh


# Optional: Geo-replica (Premium ACR)
source az/acr-replica.sh "eastus"

4. Create AKS Cluster and Node Pools

source az/init-aks.sh                # Load AKS config and variables
source az/aks.sh                     # Create AKS with initial node pool
./az/aks.sh -p "agentpool" -o "--node-count 2 --min-count 2 --max-count 6 --max-pods 250 --enable-cluster-autoscaler --load-balancer-sku Standard"
./az/aks-update.sh -o "--tags ${CC_TAGS}"      # Update tags on cluster
./az/aks-np-update.sh -p "agentpool" -o "--min-count 1 --max-count 4 --update-cluster-autoscaler"

Add More Node Pools on Different Subnets

source az/aks-np.sh -p "nptest1" -m "Standard_DS2_v2" -d "30"
source az/aks-np.sh -p "nptest2" -m "Standard_DS2_v2" -d "30"

    Ensure az/aks-np.sh includes logic to specify subnet ID using --vnet-subnet-id.

5. Public IP, DNS & Front Door

source az/dns-zone.sh
source az/ip-aks.sh "${CC_EMISSARY_IP_NAME}"
source az/ip-aks.sh "${CC_ISTIO_IP_NAME}"
source az/afd-aks.sh

6. Link ACR with AKS

source az/aks-acr-link.sh

7. View Node Pools

source az/aks-use.sh

🔐 Key Vault Integration

source az/kv.sh

🛑 Stop / Start / Destroy Infrastructure

# Stop the AKS cluster
source az/aks-stop.sh

# Start it again later
source az/aks-start.sh

# Destroy all resources (dangerous)
source az/rg-destroy.sh

📝 Notes

    Ensure you're using Azure CNI and have unique subnets for each node pool.

    Set appropriate **--vnet-subnet-id** when creating node pools.


## Sample to get started

[install-aks.sh](/doc/tutorial/aks-cluster-sample.md)