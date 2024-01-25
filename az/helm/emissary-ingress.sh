#!/bin/bash
HELM_NAME="emissary-ingress"
APP_NAME="${HELM_NAME}"
NPN=""
REPLICA_COUNT=1
ACTION="install"
VER="2.2.2"

IP_NAME=${CC_EMISSARY_IP_NAME}
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}

source bin/base.sh

H="
./az/helm/emissary-ingress.sh -a \"install\" -p \"nodepoolname\" -r \"${REPLICA_COUNT}\" 
./az/helm/emissary-ingress.sh -a \"install\" -n \"emissary-ingress\" -p \"nodepoolname\" -r \"${REPLICA_COUNT}\" -v \"${VER}\"
./az/helm/emissary-ingress.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -p \"nodepoolname\" -r \"replica-count\" -h \"helm-chart-folder-name\" 


by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 
"

help "${1}" "${H}"

while getopts a:p:n:i:r:h:v: flag
do
info "./az/helm/emissary-ingress.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        v) VER=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$VER" "VERSION" "$H"

./az/ip-aks.sh "${IP_NAME}"

export CC_AKS_RESOURCE_GROUP_NAME=`az aks show --query nodeResourceGroup --name $KS --resource-group $RG --output tsv`
MYIP=`az network public-ip show --resource-group ${CC_AKS_RESOURCE_GROUP_NAME} --name ${IP_NAME} --query ipAddress --output tsv`
empty "$MYIP" "ip under aks resource group ${CC_AKS_RESOURCE_GROUP_NAME}"

./helm/emissary-ingress.sh -a "${ACTION}" -n "${APP_NAME}" -p "${NPN}" -i "${MYIP}" -r "${REPLICA_COUNT}" -h "${HELM_NAME}" -v ${VER}

