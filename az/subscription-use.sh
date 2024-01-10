


SUB=${1:-$CC_SUBSCRIPTION}
source bin/base.sh
#az account clear



subscriptionId="$(az account list --query "[?isDefault].id" --output tsv)"
if [ "${subscriptionId}" != "$SUB" ]; then
vlog "az account list --output table"
az account list --output table
M="Your default subscription is ${subscriptionId} 
      Your given subscription is $SUB 
      Switching your $SUB to default subscription"
info "${M}"

E=`az account list --query "[?name=='${SUB}']"`
if [ "${E}" == "[]" ]; then
C="az account set --subscription ${SUB}"
ok && run-cmd "$C"
else
error "You don't belong to subscription [${SUB}]"
exit 0;
fi
# az logout
# az login
fi

subscriptionId="$(az account show --query "{subscriptionId:id}" --output tsv)"
if [ "${subscriptionId}" != "$SUB" ]; then
error "You don't belong to subscription ${SUB}"
exit 0;
else
az account set --subscription ${SUB}
fi

