# source zlink.sh

export CC_MODE=live

######## Common env variables

minio(){

env-copy-base "minio" "root-user" "MINIO_ACCESS_KEY"
env-copy-base "minio" "root-user" "MINIO_ROOT_USER"
env-copy-base "minio" "root-password" "MINIO_SECRET_KEY"
env-copy-base "minio" "root-password" "MINIO_ROOT_PASSWORD"
env-copy-base "minio" "local-url-port" "MINIO_ENDPOINT"
env-add "false" "MINIO_SECURE"

}

rabbitmq(){

env-copy-base "rabbitmq" "rabbitmq-password" "RABBITMQ_PASS"
env-copy-base "rabbitmq" "local-url" "RABBITMQ_HOST"
env-copy-base "rabbitmq" "local-port" "RABBITMQ_PORT"
env-add "${CC_RABBITMQ_USER}" "RABBITMQ_USER"

}

mariadb-galeria(){

env-add "root" "MARIADB_USER"
env-copy-base "mariadb-galera" "mariadb-root-password" "MARIADB_PASS"
env-copy-base "mariadb-galera" "local-url" "MARIADB_HOST"
env-copy-base "mariadb-galera" "local-port" "MARIADB_PORT"

}

# env-sample-api "test-api" "nstest" "7000" "api"
env-sample-api(){
#1 app-name, 2 namespace, 3 port, 4 sub-domain-name
env-file "${1}" "${2}" "${3}" "${4}"
env-add "mydbname" "MARIADB_NAME"
mariadb-galeria;rabbitmq;
env-add "/" "LOG_PATH"
env-add "ERROR" "LOG_LEVEL"
env-write  
}

# env-sample-ui "test-ui" "nstest" "80" "ui"
env-sample-ui(){
#1 app-name, 2 namespace, 3 port, 4 sub-domain-name
env-file "${1}" "${2}" "${3}" "${4}"
env-add "https://admanager.google.com" "AD_URL"
env-add-secret "sdshdsadjsadasdkadsakdskdsadsad" "CAPTCHA_KEY"
env-copy "test-api" "local-url-port" "API_HOST"
env-write  
}
