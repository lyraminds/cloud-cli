
Onboard your customer.
-------------------- 

Create create your customer environment configuration.

``````
cloud-cli/az/onboard.sh \
  -c "customer-name-no-space" \
  -e "environment-name-no-space" \ 
  -u "Aure login name with a valid Subscription" \ 
  -r "Region" \
  -s "Subscription Code" \
  -d "Domain name" \
  -v "Version no" 
``````

Example: To Create your customer's dev environment

``````
cloud-cli/az/onboard.sh \
  -c "mycustomer" \
  -e "dev" \
  -u "azureuserloginemail@domain.com" \
  -r "westus2" \
  -s "00000000-0000-0000-0000-000000000000" \
  -d "mycustomerdomain.com" \
  -v "001" 
``````

Example: To Create the above customer's uat environment in a different region

``````
cloud-cli/az/onboard.sh \
  -c "mycustomer" \
  -e "uat" \
  -u "azureuserloginemail@domain.com" \ 
  -r "eastus2" \
  -s "00000000-0000-0000-0000-000000000000" \
  -d "mycustomerdomain.com" \
  -v "001" 
``````

Example: To Create another customer's dev environment

``````
cloud-cli/az/onboard.sh \
  -c "mycustomer2" \
  -e "dev" \ 
  -u "azureuserloginemail@domain.com" \ 
  -r "eastus2" \
  -s "00000000-0000-0000-0000-000000000000" \
  -d "mycustomer2domain.com" \
  -v "001"
``````





Common Errors 
-------------

1. Check your reigon has zone support 

https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support

(InvalidAvailabilityZone) The zone(s) '1,2,3' for resource 'Microsoft.Network/publicIPAddresses/pip-dns-xxxxxxx' is not supported. The supported zones for location 'westus' are '1,2,3'
Code: InvalidAvailabilityZone
Message: The zone(s) '1,2,3' for resource 'Microsoft.Network/publicIPAddresses/pip-dns-xxxxxxxxxx' is not supported. The supported zones for location 'westus' are '1,2,3'

2. No role permission to attach acr to aks

does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write

To assign roles, you must have:

    Microsoft.Authorization/roleAssignments/write permissions, such as Role Based Access Control Administrator

    Microsoft.Authorization/roleAssignments/write
    Microsoft.Authorization/roleAssignments/delete
    
https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep
