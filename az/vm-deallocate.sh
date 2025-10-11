

source bin/base.sh

RG=${1:-$CC_RESOURCE_GROUP_NAME}
_REGION=${2:-${CC_REGION}}

RG=${CC_RESOURCE_GROUP_NAME}


H='
./az/vm-deallocate.sh -n "vmname" 
./az/vm-ssh.sh -n "vmtest" 

'

help "${1}" "${H}"

while getopts n: flag
do
info "az/vm-deallocate.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) VM_NAME=${OPTARG};;
    esac
done

empty "$VM_NAME" "VM_NAME" "$H"

# Create resource groups if it does not exist yet
if [ $(az group exists --name "$RG") == 'true' ]; then


E=`az vm list -g ${RG} --query "[?name=='${VM_NAME}']"`
if [ "${E}" != "[]" ]; then
run-cmd "az vm deallocate -g ${RG} -n ${VM_NAME}"
else
echo "VM ${VM_NAME} does not exist"
fi
fi







