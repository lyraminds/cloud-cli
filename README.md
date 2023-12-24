# Cloud-CLI

We're excited to introduce *Cloud CLI*, our next generation multi-platform command line experience for setting up kubernetes and docker environments.



## Installation



Create a workspace folder.

``````
mkdir -p workspace-cloud-cli
cd workspace-cloud-cli
``````

Get the scripts.
``````
bash -c "$(curl -L https://raw.githubusercontent.com/LyraOps/cloud-cli/main/bin/install.sh)"
``````

Note if you are not able to download. Add this ip to your host file

``````
sudo echo "185.199.108.133 raw.githubusercontent.com" >> /etc/hosts
``````


Open in Microsoft Visual code

```
code .
```

## Azure Quick Start 


Generate your first on-boarding script for azure.


``````
cloud-cli/az/onboard.sh \
  -e "dev" \
  -r "westus2" \
  -c "mycustomer" \
  -d "mycustomerdomain.com" \
  -u "azureuserloginemail@domain.com" \
  -s "00000000-0000-0000-0000-000000000000" \
  -v "001" 
``````

Go to the generated directory

Example:
``````
cd ~/workspace-cloud-cli/accounts/infra/mycustomer/dev-westus2-001

``````

Your configurations are stored in **private-azure.env**


To create an AKS cluster (Provide a valid subscription and user credentials)
``````
./install-aks.sh 
``````



## Azure Samples


Onboard your customer.
-------------------- 

Create your customer environment configuration.

``````
cloud-cli/az/onboard.sh \
  -e "environment-name-no-space" \ 
  -r "Region" \
  -c "customer-name-no-space" \
  -d "Domain name" \
  -u "Aure login name with a valid Subscription" \ 
  -s "Subscription Code" \
  -v "Version no" 
``````

Example: Create dev environment

``````
cloud-cli/az/onboard.sh \
  -e "dev" \
  -r "westus2" \
  -c "mycustomer" \
  -d "mycustomerdomain.com" \
  -u "azureuserloginemail@mycustomerdomain.com" \
  -s "00000000-0000-0000-0000-000000000000" \
  -v "001" 
``````


## Plan

| Platform   | Plan        | Doc |
|:---------------:|:------------:|:------------|
| Azure       | Preview  |  |
| AWS  | Coming Soon | |
| OCI | Coming Soon   | |
| GCP | Coming Soon    | |
| Docker  | Coming Soon   | |

## Tested on

Ubuntu 22.04
