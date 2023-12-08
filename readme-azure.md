
To onboard a customer
-------------------- 

cloud-cli/az/onboard.sh customername uat eastus2 "account.login@domain.name" "99999999-0000-0000-0000-000000000000"
cloud-cli/az/onboard.sh customername prod westus2 "account.login@domain.name" "99999999-0000-0000-0000-000000000000"



1. Add  dns nameservers if hosted in a different environment

az network dns zone show -g <resourcegroupname> -n <yourdomain.com>


Common Errors 
-------------
1. Check your reigon has zone support 
https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support

(InvalidAvailabilityZone) The zone(s) '1,2,3' for resource 'Microsoft.Network/publicIPAddresses/pip-dns-xxxxxxx' is not supported. The supported zones for location 'westus' are '1,2,3'
Code: InvalidAvailabilityZone
Message: The zone(s) '1,2,3' for resource 'Microsoft.Network/publicIPAddresses/pip-dns-xxxxxxxxxx' is not supported. The supported zones for location 'westus' are '1,2,3'

2.

does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write

To assign roles, you must have:

    Microsoft.Authorization/roleAssignments/write permissions, such as Role Based Access Control Administrator

    Microsoft.Authorization/roleAssignments/write
    Microsoft.Authorization/roleAssignments/delete
    
https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep
