


SUB=${1:-$CC_SUBSCRIPTION}

#az account clear
run-cmd "az account set --subscription $SUB"
# az account list --output table
#echo "az account set --subscription $SUB"




 