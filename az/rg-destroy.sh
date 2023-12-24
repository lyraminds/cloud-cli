

source bin/base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}

  read -sp "###################### IMPORTANT WARNING: #########################3
  This will wipe out your entire infrastructure under resource group [${RG}] in ${_REGION}
  Are you sure to delete your resource group (y/n): " YN && echo && if [ "${YN}" == "y" ]; then run-cmd "az group delete -n ${RG}"; fi

  exit


