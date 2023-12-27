
#!/bin/bash
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H="
./az/aks-np-delete.sh -n \"nodepoolname\"
"

help "${1}" "${H}"

while getopts n:c:g: flag
do
info "az/aks-np-delete.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) NPM=${OPTARG};;
        c) KS=${OPTARG};;
        g) RG=${OPTARG};;
    esac
done

empty "$NPM" "NODE POOL NAME" "$H"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPM}']"`
if [ "${E}" == "[]" ]; then

ok && run-cmd "az aks nodepool delete -g ${RG} --cluster-name ${KS} -n ${NPM}"

fi

