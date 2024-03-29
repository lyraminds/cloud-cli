
#!/bin/bash
set -e

CC_HOME=/opt/cloud-cli
CC_TEMPLATE="${CC_HOME}/az/template/*"

H="

Onboard your customer.
-------------------- 

Create your customer environment configuration.


  -e \"environment-name-no-space\" \\ 
  -r \"Region\" \\
  -c \"customer-name-no-space\" \\
  -d \"Domain name\" \\
  -u \"Aure login name with a valid Subscription\" \\ 
  -s \"Subscription Code\" \\    
  -v \"Version no\"              Version No
  -o \"vscode\"                  open in vscode 

Example: To Create your customer's dev environment


az-onboard \\
  -e \"dev\" \\
  -r \"westus2\" \\
  -c \"mycustomer\" \\
  -d \"mycustomerdomain.com\" \\
  -u \"azureuserloginemail@domain.com\" \\
  -s \"00000000-0000-0000-0000-000000000000\" \\
  -v \"001\" \\
  -o \"vscode\"

  
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
  -t \"/home/user/mytemplate\"    Use your custom template, your overrides.env and install-* files 
"


if [ "${1}" == "--help" ]; then
  echo "${help}"
  exit 0;
fi



while getopts c:e:u:r:s:d:v:t:o: flag
do
    case "${flag}" in
        c) C=${OPTARG:-customer};;
        e) E=${OPTARG:-dev};;
        u) U=${OPTARG};;
        r) R=${OPTARG};;
        s) S=${OPTARG};;
        d) D=${OPTARG};;
        v) V=${OPTARG};;
        t) T=${OPTARG};;
        o) O=${OPTARG};;
    esac
done



empty(){

if [ "$1" == "" ]; then    
    echo "ERROR: $2 is required";
    echo "$3";
    exit
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
AC="/accounts/${C}/${E}-${R}${VER}"
AC2="accounts\/${C}\/${E}-${R}${VER}"
F="`pwd`${AC}"
CF=${CC_TEMPLATE}
if [ -d "$F" ]; then
  echo "$F Already exist."
  ls -l $F
  
else
  mkdir -p $F
  cp -r $CF $F
  sed -i "s/my-cc-customer-name/${C}/g" "${F}/az.env"
  sed -i "s/my-cc-customer-env/${E}/g" "${F}/az.env"
  sed -i "s/my-cc-region/${R}/g" "${F}/az.env"  
    sed -i "s/my-cc-version/${V}/g" "${F}/az.env"  
      if [ "$D" != "" ]; then  
  sed -i "s/companydomain.com/${D}/g" "${F}/az.env"  
  fi
    
  if [ "$U" != "" ]; then  
    N=`echo "${U}" | cut -d'@' -f 1`
    sed -i "s/my-cc-name@domain.com/${U}/g" "${F}/az.env"  
    sed -i "s/my-cc-name/${N}/g" "${F}/az.env"  
    N="\${CC_GIT_LOGIN_ID}@dev.azure.com"
    sed -i "s/gitdomain.com/${N}/g" "${F}/az.env"  
    
  fi
  if [ "$S" != "" ]; then  
  sed -i "s/azure-subscription-code/${S}/g" "${F}/az.env"  
  fi
  sed -i "s/accounts/${AC2}/g" "${F}/zlink.sh"  

  echo "work/" > ${F}/.gitignore
IG="`pwd`/accounts/"
    echo "work/" > ${IG}/.gitignore
    echo "work/" > ${IG}${C}/.gitignore

echo "TEMPLATE = ${T}"
if [ "${T}" != "" ]; then 
ls -l ${T}
if [ -e "${T}/az-overrides.env" ]; then
echo "\cp -fR \"${T}/az-overrides.env\" \"${F}/az-overrides.env\""
\cp -fR "${T}/az-overrides.env" ${F}/az-overrides.env
fi
if [ -e "${T}/install-aks.sh" ]; then
echo "\cp -fR \"${T}/install-aks.sh\" \"${F}/install-aks.sh\""
\cp -fR "${T}/install-aks.sh" ${F}/install-aks.sh
fi
if [ -e "${T}/deploy-app.sh" ]; then
echo "\cp -fR \"${T}/deploy-app.sh\" \"${F}/deploy-app.sh\""
\cp -fR "${T}/deploy-app.sh" ${F}/deploy-app.sh
fi
if [ -e "${T}/deploy-base.sh" ]; then
echo "\cp -fR \"${T}/deploy-base.sh\" \"${F}/deploy-base.sh\""
\cp -fR "${T}/deploy-base.sh" ${F}/deploy-base.sh
fi
if [ -e "${T}/build-docker.sh" ]; then
echo "\cp -fR \"${T}/build-docker.sh\" \"${F}/build-docker.sh\""
\cp -fR "${T}/build-docker.sh" ${F}/build-docker.sh
fi
if [ -e "${T}/build-charts.sh" ]; then
echo "\cp -fR \"${T}/build-charts.sh\" \"${F}/build-charts.sh\""
\cp -fR "${T}/build-charts.sh" ${F}/build-charts.sh
fi
if [ -e "${T}/env-vars.sh" ]; then
echo "\cp -fR \"${T}/env-vars.sh\" \"${F}/env-vars.sh\""
\cp -fR "${T}/env-vars.sh" ${F}/env-vars.sh
fi
if [ -e "${T}/install-np.sh" ]; then
echo "\cp -fR \"${T}/install-np.sh\" \"${F}/install-np.sh\""
\cp -fR "${T}/install-np.sh" ${F}/install-np.sh
fi

fi


fi

echo "----------------------------------------------------------------"
echo "Configuration is generated at: ${F}"
if [ "$O" == "vscode" ] || [ "$O" == "code" ]; then 
cd ${F}
code .
else
echo "cd ${F}"
fi
echo "----------------------------------------------------------------"
# cd ${CD}

