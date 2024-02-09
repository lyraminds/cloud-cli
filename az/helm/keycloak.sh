#!/bin/bash
HELM_NAME="keycloak"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=2
ACTION="install"
DISK=32Gi
THEME_IMG=""
SUB_DOMAIN=${APP_NAME}
THEME_VER=""
###Custom theme folder in theme image to copy
THEME_FOLDER=""
#==============================================
source bin/base.sh
H="
./helm/keycloak.sh -a \"install\" -s \"common-namespace\" -p \"nodepoolname\" -d \"${DISK}\" -r \"${REPLICA_COUNT}\" 
./helm/keycloak.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"common-namespace\" -p \"nodepoolname\" -d \"disk-space\" -r \"replica-count\" -h \"helm-chart-folder-name\" 

Using custom theme

-t \"keycloak-theme\" -v \"1.0\" -f \"mytheme\" 
-t \"custom-theme-docker-image\" -v \"theme-docker-image-version\" -f \"custom-theme-folder-inside-docker-image\" 

To Create Realm define the realms in your xxx-overrides.env

export CC_KEYCLOAK_REALM_NAME=
export CC_KEYCLOAK_CLIENT_NAME=
export CC_KEYCLOAK_CLIENT_SECRET=


by default app name is helm folder name

-h helm-chart-folder-name 
-n app-name 

"

help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:t:e:f:v: flag
do
info "helm/keycloak.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        d) DISK=${OPTARG};;
        e) SUB_DOMAIN=${OPTARG};;
        t) THEME_IMG=${OPTARG};;
        v) THEME_VER=${OPTARG};;
        f) THEME_FOLDER=${OPTARG};;
    esac
done

empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$DISK" "DISK" "$H"
empty "$SUB_DOMAIN" "SUB DOMAIN" "$H"

./helm/keycloak.sh -n "${APP_NAME}" -s "${NS}" -p "${NPN}" -a "${ACTION}" -r "${REPLICA_COUNT}" -h "${HELM_NAME}" -d "${DISK}" -e "${SUB_DOMAIN}" -t "${THEME_IMG}" -v "${THEME_VER}" -f "${THEME_FOLDER}"

if [ "${ACTION}" == "install" ]; then
./az/afd-aks-origin.sh -n "`fqn ${SUB_DOMAIN}`"
fi