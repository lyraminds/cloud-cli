## How To define Environment variable for your deployment

You define your environment variables, secret, config map, host mapping etc in env-vars

**Create env-vars.sh**

Define common base properties for all deployments.
These are private functions

```sh
rabbitmq(){
env-copy-secret "rabbitmq" "rabbitmq-password" "RABBITMQ_PASS"
env-copy "rabbitmq" "local-url" "RABBITMQ_HOST"
env-copy "rabbitmq" "local-port" "RABBITMQ_PORT"
env-add "${CC_RABBITMQ_USER}" "RABBITMQ_USER"
}

mariadb-galeria(){
env-add "root" "MARIADB_USER"
env-copy-secret "mariadb-galera" "mariadb-root-password" "MARIADB_PASS"
env-copy "mariadb-galera" "local-url" "MARIADB_HOST"
env-copy "mariadb-galera" "local-port" "MARIADB_PORT"
}

keycloak(){
env-add "${CC_KEYCLOAK_CLIENT_NAME}" "KEYCLOAK_CLIENT_ID"
env-add "${CC_KEYCLOAK_CLIENT_SECRET}" "KEYCLOAK_CLIENT_SECRET"
env-add "${CC_KEYCLOAK_REALM_NAME}" "KEYCLOAK_REALM_NAME"
env-url-public "keycloak" "KEYCLOAK_SERVER_URL"
}

```

**Define env vars for front end UI**

```sh
env-app-ui(){
env-file "${1}" "${2}" "${3}" "${4}"
env-write '
          volumeMounts:
          - name: env
            mountPath: /usr/local/apache2/htdocs/env.js
            subPath: env.js
          - name: httpdconf
            mountPath: /usr/local/apache2/conf/httpd.conf
            subPath: httpd.conf

      volumes:
      - name: env
        configMap:
          name: env
      - name: httpdconf
        configMap:
          name: httpdconf
'

## To create a config map

export SD_UI_FQN=$(fqhn "${SD_UI}")
export SD_PAY_FQN=$(fqhn "${SD_PAY}")
export SD_API_FQN=$(fqhn "${SD_API}")

# Process template with environment variables
env-add-config-map "${1}" "SD_UI_FQN" "SD_PAY_FQN" "SD_API_FQN"


## Extra value in host mapping 

env-append-host-mapping '
  add_request_headers:
    X-ProxyPort:
      value: "443"
    X-ProxyScheme:
      value: https
'

}
```

----

**Deploy env vars for your backend API**

```sh
env-app-api(){

## Create env file
env-file "${1}" "${2}" "${3}" "${4}"

## Add the common environments
mariadb-galeria;rabbitmq;keycloak;

## Same as using directly in env-write
env-add "/" "LOG_PATH"
env-add "ERROR" "LOG_LEVEL"

env-add "true" "AUDIT_ENABLE"
env-add "${CC_KEYCLOAK_ADMIN_USER}" "KEYCLOAK_ADMIN_USER_ID"

## Copy keycloak secret
env-copy-secret "keycloak" "admin-password" "KEYCLOAK_ADMIN_PASS"

## Copy rabinmq local url
env-url "rabbitmq" "MESSAGE_LOCAL_URL"

## Copy keycloak public url
env-url-public "keycloak" "KEYCLOAK_HOST"

## Adding a custom subdomain url
env-add "https://$(fqhn ${SD_UI})" "APP_HOST_URL"

## Wite the content to env and create secret
env-write '
              - name: LOG_PATH
                value: /
              - name: LOG_LEVEL
                value: DEBUG          
              - name: NAMESPACE
                value: ns-api                                            

'
}
```

---

## Reference

[env-vars](/doc/env-vars.md)

## Sample

[deploy-app](/doc/tutorial/deploy-app-sample.md)