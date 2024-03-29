
#!/bin/bash
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H="
./az/aks-np-delete.sh -p \"nodepoolname\"
"

help "${1}" "${H}"

while getopts p:c:g: flag
do
info "az/aks-np-delete.sh ${flag} ${OPTARG}"
    case "${flag}" in
        p) NPN=${OPTARG};;
        c) KS=${OPTARG};;
        g) RG=${OPTARG};;
    esac
done

empty "$NPN" "NODE POOL NAME" "$H"

E=`az aks nodepool list -g ${RG} --cluster-name ${KS} --query "[?name=='${NPN}']"`
if [ "${E}" != "[]" ]; then
ok && run-cmd "az aks nodepool delete -g ${RG} --cluster-name ${KS} -n ${NPN}"
fi

