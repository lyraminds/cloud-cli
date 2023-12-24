
#!/bin/bash
set -e

H="

Onboard your customer.
-------------------- 

Create create your customer environment configuration.


cloud-cli/az/onboard.sh \\
  -e \"environment-name-no-space\" \\ 
  -r \"Region\" \\
  -c \"customer-name-no-space\" \\
  -d \"Domain name\" \\
  -u \"Aure login name with a valid Subscription\" \\ 
  -s \"Subscription Code\" \\
  -v \"Version no\" 


Example: To Create your customer's dev environment


cloud-cli/az/onboard.sh \\
  -e \"dev\" \\
  -r \"westus2\" \\
  -c \"mycustomer\" \\
  -d \"mycustomerdomain.com\" \\
  -u \"azureuserloginemail@domain.com\" \\
  -s \"00000000-0000-0000-0000-000000000000\" \\
  -v \"001\" 


Example: To Create the above customer's uat environment in a different region


cloud-cli/az/onboard.sh \\
cloud-cli/az/onboard.sh \\
  -e \"uat\" \\
  -r \"westus2\" \\
  -c \"mycustomer\" \\
  -d \"mycustomerdomain.com\" \\
  -u \"azureuserloginemail@domain.com\" \\
  -s \"00000000-0000-0000-0000-000000000000\" \\
  -v \"001\" 


Example: To Create another customer's dev environment


cloud-cli/az/onboard.sh \\
  -e \"dev\" \\ 
  -r \"eastus2\" \\
  -c \"mycustomer2\" \\
  -d \"mycustomer2domain.com\" \\
  -u \"azureuserloginemail@domain.com\" \\ 
  -s \"00000000-0000-0000-0000-000000000000\" \\
  -v \"001\"


"


if [ "${1}" == "--help" ]; then
  echo "${help}"
  exit 0;
fi



while getopts c:e:u:r:s:d:v: flag
do
    case "${flag}" in
        c) C=${OPTARG:-customer};;
        e) E=${OPTARG:-dev};;
        u) U=${OPTARG};;
        r) R=${OPTARG};;
        s) S=${OPTARG};;
        d) D=${OPTARG};;
        v) V=${OPTARG:-001};;
    esac
done



empty(){

if [ "$1" == "" ]; then    
    echo "ERROR: $2 is required";
    echo "$3";
    return
fi
}

# CD=`pwd`
# source cloud-cli/base.sh

empty "$C" "Customer" "${H}"
empty "$E" "Environment" "${H}"
empty "$R" "Region" "${H}"
empty "$U" "Login User Name" "${H}"
empty "$S" "Subscription code" "${H}"
empty "$D" "Domain Name" "${H}"

VER=''
if [ "$V" != "" ]; then 
VER="-${V}"
fi
AC="/accounts/infra/${C}/${E}-${R}${VER}"
AC2="accounts\/infra\/${C}\/${E}-${R}${VER}"
F="`pwd`${AC}"
CF="`pwd`/cloud-cli/az/template/*"
if [ -d "$F" ]; then
  echo "$F Already exist."
  ls -l $F
  
else
  mkdir -p $F
  cp -r $CF $F
  sed -i "s/demo/${C}/g" "${F}/private-azure.env"
  sed -i "s/dev/${E}/g" "${F}/private-azure.env"
  sed -i "s/westus2/${R}/g" "${F}/private-azure.env"  
    sed -i "s/001/${V}/g" "${F}/private-azure.env"  
      if [ "$D" != "" ]; then  
  sed -i "s/companydomain.com/${D}/g" "${F}/private-azure.env"  
  fi
    
  if [ "$U" != "" ]; then  
    N=`echo "${U}" | cut -d'@' -f 1`
    sed -i "s/myname@domain.com/${U}/g" "${F}/private-azure.env"  
    sed -i "s/myname/${N}/g" "${F}/private-azure.env"  
  fi
  if [ "$S" != "" ]; then  
  sed -i "s/azure-subscription-code/${S}/g" "${F}/private-azure.env"  
  fi
  sed -i "s/accounts/${AC2}/g" "${F}/zlink.sh"  

  echo "work/" > ${F}/.gitignore
IG="`pwd`/accounts/infra/"
    echo "work/" > ${IG}/.gitignore
    echo "work/" > ${IG}${C}/.gitignore

  
fi

echo "##"
echo "Your infra configuration's are available at"
echo "cd ${F}"
# cd ${CD}

