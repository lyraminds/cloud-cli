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

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

HNAME="$(fqhn $APP_NAME)"
export CC_KEYCLOAK_PUBLIC_URL=https://${HNAME}
export CC_KEYCLOAK_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local


SECRET=keycloak-secret
if [ "${ACTION}" == "install" ]; then

secret-file "${SECRET}"
secret-add "${CC_KEYCLOAK_MANAGEMENT_PASSWORD}" "management-password" 
secret-add "${CC_KEYCLOAK_ADMIN_PASSWORD}" "admin-password" 
secret-add "${CC_KEYCLOAK_POSTGRES_PASSWORD}" "password" 
secret-add "${CC_KEYCLOAK_POSTGRES_ROOT_PASSWORD}" "postgres-password" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local" "keycloak-local-url" 
secret-add "80" "keycloak-local-port"
secret-add "${APP_NAME}.${NS}.svc.cluster.local:80" "keycloak-local-url-port" 
./kube/secret.sh "${SECRET}" "${NS}"

fi

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-overrides.yaml"

#================================================

echo " 

metrics: 
  enabled: false 

auth:
  adminUser: \"${CC_KEYCLOAK_ADMIN_USER}\"
  existingSecret: \"$SECRET\"

postgresql:
  enabled: true
  auth:
    username: \"${CC_KEYCLOAK_POSTGRES_USERNAME}\"
    database: \"${CC_KEYCLOAK_POSTGRES_DATABASE}\"
    existingSecret: \"$SECRET\"

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 3


service:
  type: \"ClusterIP\"


proxyAddressForwarding: true
extraEnvVars: 
  - name: KEYCLOAK_FRONTEND_URL 
    value: \"${CC_KEYCLOAK_PUBLIC_URL}\" 
  - name: KEYCLOAK_LOG_LEVEL 
    value: \"ERROR\" 
  - name: KEYCLOAK_PROXY_ADDRESS_FORWARDING 
    value: \"true\" 

    " > ${OVR}

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

if [ ! -z "${CC_KEYCLOAK_REALM_NAME}" ] && [ ! -z "${CC_KEYCLOAK_CLIENT_NAME}" ] ; then
echo "
keycloakConfigCli:
  enabled: true
  backoffLimit: 1
  command:
    - \"java\"
    - \"-jar\"
    - \"/opt/bitnami/keycloak-config-cli/keycloak-config-cli.jar\"
  configuration:
    ${CC_KEYCLOAK_REALM_NAME}.json: |
      {
        \"enabled\": true,
        \"realm\": \"${CC_KEYCLOAK_REALM_NAME}\",
        \"clients\": [
          {
            \"clientId\": \"${CC_KEYCLOAK_CLIENT_NAME}\",
            \"name\": \"${CC_KEYCLOAK_CLIENT_NAME}\",
            \"enabled\": true,
            \"clientAuthenticatorType\": \"client-secret\",
            \"secret\": \"${CC_KEYCLOAK_CLIENT_SECRET}\",
            \"redirectUris\": [
              \"*\"
            ],
            \"webOrigins\": [
              \"*\"
            ]
          }
        ]
      }      
"  >> ${OVR}
else
info "Skiping relm configuration, Define CC_KEYCLOAK_REALM_NAME, CC_KEYCLOAK_CLIENT_NAME and CC_KEYCLOAK_CLIENT_SECRET in xxx-overrides.env"
fi
##if custom theme then do this

export APP_IMG="${THEME_IMG}"
if [ ! -z "$THEME_VER" ]; then
export APP_IMG="${CC_CONTAINER_IMAGE_PREFIX}${THEME_IMG}:${THEME_VER}"
fi

#TODO may have to pass for other clusters
export THEME_IMG_URL="${CC_CONTAINER_REGISTRY_URL}/${APP_IMG}"

if [ ! -z "${THEME_FOLDER}" ] && [ ! -z "${THEME_IMG}" ] ; then
echo "
initContainers: |
    - name: keycloak-theme-provider
      image: ${THEME_IMG_URL}
      imagePullPolicy: Always
      resources:
        limits:
          cpu: \"20m\"
          memory: \"64Mi\"
        requests:
          cpu: \"10m\"
          memory: \"32Mi\"
      command:
        - sh
      args:
        - -c
        - |
          echo \"Copying theme...\"
          cp -R /${THEME_FOLDER}/* /theme
      volumeMounts:
        - name: theme
          mountPath: /theme

extraVolumeMounts:
  - name: theme
    mountPath: /opt/bitnami/keycloak/themes/custom

extraVolumes:
  - name: theme
    emptyDir: {}

" >> ${OVR}
else
info "Skiping custom theme, Use -i \"custom-keycloak-theme-image\" and -t \"theme-folder-in-custom-image-to-copy\" "
fi
#storageClass: managed-premium,

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "2"

if [ "${ACTION}" == "install" ]; then
./kube/emissary-host-mapping.sh "${APP_NAME}" "${NS}" "${APP_NAME}.${NS}.svc:80" "${SUB_DOMAIN}"
fi

