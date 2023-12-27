# Cloud-CLI

We're excited to introduce *Cloud CLI*, our next generation multi-platform command line experience for setting up kubernetes and docker environments.



## Installation

Get the scripts.
``````
bash -c "$(curl -L https://raw.githubusercontent.com/lyraminds/cloud-cli/main/bin/install.sh)"
``````

Note if you are not able to download, add to your host file.

``````
sudo echo "185.199.108.133 raw.githubusercontent.com" >> /etc/hosts
``````


## Azure Quick Start 


Create a workspace folder.

``````
mkdir -p workspace-cloud-cli
cd workspace-cloud-cli
``````

Generate your first on-boarding script for Azure.


``````
az-onboard \
  -e "dev" \
  -r "westus2" \
  -c "mycompany" \
  -d "mycompanydomain.com" \
  -u "azureuserloginemail@mycompanydomain.com" \
  -s "00000000-0000-0000-0000-000000000000" \
  -v "001" 
``````


``````
  Required

  -e \"dev\"                      Environment Name eg dev, qa, uat, prod 
  -r \"westus2\"                  Azure Region
  -c \"mycustomer\"               Name of your client
  -d \"mycustomerdomain.com\"                 Domain name to be used for your project
  -u \"azureuserloginemail@domain.com\"       Azure login id
  -s \"00000000-0000-0000-0000-000000000000\" Azure Subscription code
  -v \"001\"                      Version No

  Optional

  -o \"vscode\"                   Open the generated configuration in vscode
  -t \"/home/user/mytemplate\"    Use your custom template, replaces overrides.env and install-* files. 
``````

Go to the generated directory

``````
cd ~/workspace-cloud-cli/accounts/infra/mycompany/dev-westus2-001

``````

Your configurations are stored in **az.env**


To create an AKS cluster (You need a valid Azure subscription and user credentials)
``````
./install-aks.sh 
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
