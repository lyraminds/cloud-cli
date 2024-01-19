

source bin/base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}

  # read -sp "###################### IMPORTANT WARNING: #########################3
  # This will wipe out your entire infrastructure under resource group [${RG}] in ${_REGION}
  # Are you sure to delete your resource group (y/n): " YN && echo && if [ "${YN}" == "y" ]; then run-cmd "az group delete -n ${RG}"; fi

 
echo "
###################### IMPORTANT WARNING: #########################
This will wipe out your entire infrastructure under resource group [${RG}] in ${_REGION}
"
read -p "Are you sure to delete your resource group (y/n):" YN

#Print output based on the input

if [ "$YN" == "y" ]; then
run-cmd "az group delete -n ${RG}"
elif [ "$YN" == "n" ]; then
echo "You choose to cancel"
else
echo "Invalid option use y or n"
fi

 exit