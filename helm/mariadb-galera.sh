#!/bin/bash
HELM_NAME="mariadb-galera"
APP_NAME="${HELM_NAME}"
NS=""
NPN=""
REPLICA_COUNT=1
ACTION="install"
DISK=16Gi
DB_NAME="${CC_MYSQL_DATABASE}"
DB_USER="${CC_MYSQL_USERNAME}"
#==============================================
source bin/base.sh
H="
./helm/mariadb-galera.sh -a \"install\" -s \"data-namespace\" -p \"npdata\" -d \"16Gi\" -r \"1\" 
./helm/mariadb-galera.sh -a \"install\" -s \"data-namespace\" -p \"npdata\" -d \"16Gi\" -u "database-user" -b "database-name" -r \"1\" 
./helm/mariadb-galera.sh -a \"install|upgrade|uninstall\" -n \"app-name\" -s \"data-namespace\" -p \"nodepoolname\" -d \"disk-space\" -u "database-user" -b "database-name" -r \"replica-count\" -h \"helm-chart-folder-name\" 

by default app name is helm folder name
-h helm-chart-folder-name 
-n app-name 

"


help "${1}" "${H}"

while getopts a:p:n:s:r:h:d:b:u: flag
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
    esac
done

HELM_FOLDER=${CC_HELM_CHARTS_ROOT}/${HELM_NAME}

empty "$DB_USER" "Database New User Name" "$H"
empty "$DB_NAME" "Database Name" "$H"
empty "$APP_NAME" "APP NAME" "$H"
empty "$NS" "NAMESPACE" "$H"
empty "$NPN" "NODE POOL NAME" "$H"
empty "$ACTION" "ACTION" "$H"
empty "$REPLICA_COUNT" "REPLICA_COUNT" "$H"
empty "$HELM_NAME" "HELM_NAME" "$H"
empty "$DISK" "DISK" "$H"

export CC_MYSQL_SERVICE_URL=${APP_NAME}.${NS}.svc.cluster.local

SECRET=${APP_NAME}-secret
OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-overrides.yaml"

echo " 
podManagementPolicy: \"Parallel\"
replicaCount: ${REPLICA_COUNT}
galera:
  bootstrap:
    forceBootstrap: true
    bootstrapFromNode: 0
    forceSafeToBootstrap: true

persistence:
  size: \"${DISK}\"

metrics:
  enabled: false      
existingSecret: \"$SECRET\"

db:
  user: \"${DB_USER}\"
  name: \"${DB_NAME}\"

# initdbScripts:
#   my_init_script.sh: |
#      #!/bin/sh
#      echo \"====================================$(hostname)\"
#      if [[ $(hostname) == *-0  ]]; then
#        mysql -P 3306 -uroot -p${CC_MYSQL_ROOT_PASSWORD} -e \"grant all privileges on *.* TO '${CC_MYSQL_ROOT_USERNAME}'@'10.%' identified by '${CC_MYSQL_ROOT_PASSWORD}';flush privileges;\";
#        mysql -P 3306 -uroot -p${CC_MYSQL_ROOT_PASSWORD} -e \"grant all privileges on ${DB_NAME}.* TO '${DB_USER}'@'10.%' identified by '${CC_MYSQL_USER_PASSWORD}';flush privileges;\";
#      fi
    " > $OVR
  
# if [ "${ACTION}" == "install" ]; then
# ./kube/ns.sh $NS
# fi

#toleration and taint
./kube/set-taint.sh "${NPN}" "${OVR}"

#define secret and create
secret-file "${SECRET}" "${CC_MYSQL_USER_PASSWORD}" "mariadb-password" 
secret-add "${SECRET}" "${CC_MYSQL_ROOT_PASSWORD}" "mariadb-root-password"
secret-add "${SECRET}" "${CC_MYSQL_BACKUP_PASSWORD}" "mariadb-galera-mariabackup-password" 
./kube/secret.sh "${SECRET}" "${NS}"

run-helm "${ACTION}" "${APP_NAME}" "$NS" "${HELM_FOLDER}" "$OVR"
run-sleep "3"

vlog "kubectl -n "$NS" describe service ${APP_NAME}"



