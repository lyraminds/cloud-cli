
C=$1
E=$2
R=$3
U=$4
S=$5

empty(){

if [ "$1" == "" ]; then    
    echo "ERROR: $2 is required";
    echo "$3";
    exit;
fi
}

CD=`pwd`

H="

cloud-cli/az/onboard \"customer-name-no-space\" \"environment-name-no-space\" \"Region\" \"azureuserloginemail@domain.com\" \"Subscribtion Code\"
cloud-cli/az/onboard \"demo\" \"dev\" \"westus2\"
cloud-cli/az/onboard \"demo\" \"uat\" \"eastus2\"

cloud-cli/az/onboard \"demo\" \"prod\" \"westus2\" \"name@domain.com\" \"238494d-dsds-ewwewe-dsdsdfdfs\"


"
empty "$1" "Customer" "${H}"
empty "$2" "Environment" "${H}"
empty "$3" "Region" "${H}"

AC="/accounts2/infra/${C}/${E}-${R}"
AC2="accounts2\/infra\/${C}\/${E}-${R}"
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
  if [ "$4" != "" ]; then  
    N=`echo "${4}" | cut -d'@' -f 1`
    sed -i "s/myname@domain.com/${4}/g" "${F}/private-azure.env"  
    sed -i "s/myname/${N}/g" "${F}/private-azure.env"  
  fi
  if [ "$5" != "" ]; then  
  sed -i "s/azure-subscription-code/${5}/g" "${F}/private-azure.env"  
  echo "work" > ${F}/.gitignore
  fi

  sed -i "s/accounts/${AC2}/g" "${F}/zlink.sh"  
  
fi

echo "Go to this account to start using"
echo "cd ${F}"
# cd ${CD}

