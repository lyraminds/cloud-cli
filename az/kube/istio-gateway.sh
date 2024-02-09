#!/bin/bash
APP_NAME="istio-gateway"
ACTION="install"
SUB_DOMAIN=${APP_NAME}
IP_NAME=${CC_ISTIO_IP_NAME}

source bin/base.sh

H="
./az/helm/istio-gateway.sh -a \"install\" -n "app-name" -e \"subdomain\" 
./az/helm/istio-gateway.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -e \"sub-domain\"

"

help "${1}" "${H}"

while getopts a:n:e: flag
do
info "az/helm/istio-gateway.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        a) ACTION=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$SUB_DOMAIN" "SUB DOMAIN" "$H"


./kube/istio-gateway.sh -a "${ACTION}" -n "${APP_NAME}" -e ${SUB_DOMAIN}

./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN}`" -i "${IP_NAME}"



