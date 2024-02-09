#!/bin/bash
APP_NAME="istio"
NPN=""
REPLICA_COUNT=1
ACTION="install"
VER=1.14.0
IP_NAME=${CC_ISTIO_IP_NAME}
KS=${CC_AKS_CLUSTER_NAME}
RG=${CC_RESOURCE_GROUP_NAME}
SUB_DOMAIN=${APP_NAME}
source bin/base.sh
H="
./helm/istio.sh -a \"install\" -p \"nodepoolname\" -r \"${REPLICA_COUNT}\" -v \"${VER}\" 
./helm/istio.sh -a \"install\" -p \"nodepoolname\" -r \"${REPLICA_COUNT}\" -v \"${VER}\" -n \"${APP_NAME}\"   
./helm/istio.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -r \"replica-count\" -v \"istio-version\"  

"

help "${1}" "${H}"

while getopts a:p:n:r:v:e: flag
do
info "helm/istio.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        v) VER=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$VER" "ISIO VERSION" "$H"

./az/ip-aks.sh "${IP_NAME}"

export CC_AKS_RESOURCE_GROUP_NAME=`az aks show --query nodeResourceGroup --name $KS --resource-group $RG --output tsv`
MYIP=`az network public-ip show --resource-group ${CC_AKS_RESOURCE_GROUP_NAME} --name ${IP_NAME} --query ipAddress --output tsv`
empty "$MYIP" "ip under aks resource group ${CC_AKS_RESOURCE_GROUP_NAME}"

./helm/istio.sh -a "${ACTION}" -n "${APP_NAME}" -p "${NPN}" -r "${REPLICA_COUNT}" -v ${VER} -i "${MYIP}" -e "${SUB_DOMAIN}"

if [ "${ACTION}" == "install" ]; then
./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN}`" -i "${IP_NAME}"
fi