


SUB=${1:-$CC_SUBSCRIPTION}
source bin/base.sh
#az account clear
vlog "az account list --output table"


subscriptionId="$(az account list --query "[?isDefault].id" --output tsv)"
if [ "${subscriptionId}" != "$SUB" ]; then
az account list --output table
info "Your default subscription is ${subscriptionId} 
      Your given subscription is $SUB 
      Switching your $SUB to default subscription"
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

