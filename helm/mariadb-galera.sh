#!/bin/bash
HELM_NAME="mariadb-galera"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=1
ACTION="install"
DISK=16Gi

OVER_WRITE="true"
#==============================================
source bin/base.sh
H="
./helm/mariadb-galera.sh -a \"install\" -s \"data-namespace\" -p \"npdata\" -d \"16Gi\" -r \"${REPLICA_COUNT}\" 
./helm/mariadb-galera.sh -a \"install\" -s \"data-namespace\" -p \"npdata\" -d \"16Gi\" -u "database-user" -b "database-name" -r \"1\" 
./helm/mariadb-galera.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"data-namespace\" -p \"nodepoolname\" -d \"disk-space\" -u "database-user" -b "database-name" -r \"replica-count\" -h \"helm-chart-folder-name\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

-w true

"


help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:b:u:w:l: flag
do
info "helm/mariadb-galera.sh ${flag} ${OPTARG}"
    case "${flag}" in
        n) APP_NAME=${OPTARG};;
        p) NPN=${OPTARG};;
        s) NS=${OPTARG};;
        r) REPLICA_COUNT=${OPTARG};;
        a) ACTION=${OPTARG};;
        h) HELM_NAME=${OPTARG};;
        d) DISK=${OPTARG};;
        b) DB_NAME=${OPTARG};;
        u) DB_USER=${OPTARG};;
        w) OVER_WRITE=${OPTARG};;
        l) _SD_REGION=${OPTARG};;  
    esac
done

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}


empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$DISK" "DISK" "$H"

if [ ! -z "${_SD_REGION}" ] && [ "${_SD_REGION}" != "" ]; then
CV=""
if [ "${CC_RESOURCE_VERSION}" != "" ]; then
CV="_${CC_RESOURCE_VERSION}"
fi
DB_PREFIX="${CC_CUSTOMER}_${_SD_REGION}${CV}"

DB_NAME="${DB_PREFIX}_db"
DB_USER="${DB_PREFIX}_user"

APP_NAME=${APP_NAME}-${_SD_REGION}
fi
# export CC_MYSQL_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local

if [ -z "${DB_USER}" ] || [ "${DB_USER}" == "" ]; then
DB_USER="${CC_MYSQL_USERNAME}"
fi
if [ -z "${DB_NAME}" ] || [ "${DB_NAME}" == "" ]; then
DB_NAME="${CC_MYSQL_DATABASE}"
fi

empty "$DB_USER" "Database New User Name" "$H"
empty "$DB_NAME" "Database Name" "$H"

SECRET=${APP_NAME}-secret
if [ "${ACTION}" == "install" ]; then

#define secret and create
secret-file "${SECRET}"
secret-add "${DB_USER}" "mariadb-user" 
secret-add "${DB_NAME}" "mariadb-db" 
secret-add "${CC_MYSQL_USER_PASSWORD}" "mariadb-password" 
secret-add "${CC_MYSQL_ROOT_PASSWORD}" "mariadb-root-password"
secret-add "${CC_MYSQL_BACKUP_PASSWORD}" "mariadb-galera-mariabackup-password" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local" "local-url" 
secret-add "3306" "local-port" 
secret-add "${APP_NAME}.${NS}.svc.cluster.local:3306" "local-url-port" 
./kube/secret.sh "${SECRET}" "${NS}"

vlog "kubectl -n "$NS" describe service ${APP_NAME}"

fi

DPF="${CC_BASE_DEPLOY_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-overrides.yaml"

if [ "${OVER_WRITE}" == "true" ] || [ ! -f "${OVR}" ]; then



echo " 

replicaCount: ${REPLICA_COUNT}

persistence:
  size: \"${DISK}\"

metrics:
  enabled: false      
existingSecret: \"$SECRET\"

db:
  user: \"${DB_USER}\"
  name: \"${DB_NAME}\"

    " > $OVR

# initdbScripts:
#   my_init_script.sh: |
#      #!/bin/sh
#      echo \"====================================$(hostname)\"
#      if [[ $(hostname) == *-0  ]]; then
#        mysql -P 3306 -uroot -p${CC_MYSQL_ROOT_PASSWORD} -e \"grant all privileges on *.* TO '${CC_MYSQL_ROOT_USERNAME}'@'10.%' identified by '${CC_MYSQL_ROOT_PASSWORD}';flush privileges;\";
#        mysql -P 3306 -uroot -p${CC_MYSQL_ROOT_PASSWORD} -e \"grant all privileges on ${DB_NAME}.* TO '${DB_USER}'@'10.%' identified by '${CC_MYSQL_USER_PASSWORD}';flush privileges;\";
#      fi



if [ ! -f "${CC_MARIADB_DEPLOYMENT}" ]; then
echo "---------------------- INFO ------------------------"
echo "No mariadb custom deployments found at [${CC_MARIADB_DEPLOYMENT}], define right path at [CC_MARIADB_DEPLOYMENT] in xx-overrides.env"
echo "Will continue with out additonal custom configuration for mariadb in 3 sec..."
echo "---------------------- INFO ------------------------"
sleep "3"
else
cat ${CC_MARIADB_DEPLOYMENT} >> ${OVR}
fi

  #toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}" "TAB0"

fi

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"

# kubectl -n "$NS" logs -p "${APP_NAME}-0" --previous --tail 10



