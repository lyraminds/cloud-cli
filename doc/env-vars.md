
# Shell Script env-vars Documentation


## `env-file`

**Description:**
Generates an environment file with secrets and mappings.

**Parameters:**
- `$1`: Environment file name
- `$2`: Namespace
- `$3`: Port number
- `$4`: Subdomain

**Usage:**
```sh
env-file "my-app" "my-namespace" "8080" "subdomainname"
```


## `env-copy`

**Description:**
Copies an existing environment variable of a previously deployed application.

**Parameters:**
- `$1`: Application name
- `$2`: Key name
- `$3`: Environment name
- `$4`: Prefix (optional)

**Usage:**
```sh
env-copy "base-db" "db-url" "DB_URL"
```

Copy the value in "db-url" file from "base-db" project to "DB_URL"

---

## `env-copy-secret`

**Description:**
Copies an existing secret of a previously deployed application and assigns it to an environment variable. Eg database password.

**Parameters:**
- `$1`: Application name
- `$2`: Secret key
- `$3`: New Secret key name (optional, defaults to secret key)
- `$4`: Prefix (optional)


**Usage:**
```sh
env-copy-secret "base-db" "db-password" "DB_PASS"
```
Copy the value in "db-password" file from "base-db" project to "DB_PASS" and create a secret if env-write is applied.

---


## `env-add`

**Description:**
Sets environment variables and substitutes them in a YAML file.
Alternatively you could use "env-set" or "env-write"

**Parameters:**
- `$1`: Environment value
- `$2`: Environment name

**Usage:**

```sh
env-add "value" "name"
```

**Example:**

```sh
env-add "my-db" "MARIADB_NAME"
env-add "https://$(fqhn ${SD_API})/jobs/access_token" "ACCESS_TOKEN_API_URL" 
env-add "https://$(fqhn ${SD_UI})" "UI_URL"
```


---

## `env-add-secret`

**Description:**
Adds a secret to the environment and substitutes it in a YAML file.

**Parameters:**
- `$1`: Secret value
- `$2`: Secret key

**Usage:**
```sh
env-add-secret "aEDdpd80400fsddfllfd997kgpg" "api-key"
```

---

## `env-url`

**Description:**
Copies the local-url-port of a previously deployed application to an environment variable.
http:// for local urls

**Parameters:**
- `$1`: Application name
- `$2`: Local url key name i.e local-url-port
- `$3`: Additional path (optional)

**Usage:**
```sh
env-url "my-backend" "API_URL"
```

**Example:**
```sh
env-url "backend-api" "API_URL" "/v2"
```
Copy the value in "local-url-port" file from "backend-api" project to "API_URL" and append "/v2"

Eg:- http://backend-api.my-namespace.svc.cluster.local:80/v2

---

## `env-url-public`

**Description:**
Creates a public HTTPS URL environment variable.

**Parameters:**
- `$1`: Application name
- `$2`: Piblic url key i.e public-url
- `$3`: Additional path (optional)

**Usage:**
```sh
env-url-public "my-backend" "443"
```

**Example:**
```sh
env-url-public "backend-api" "API_URL" "/v2"
```
Copy the value in "local-url-port" file from "backend-api" project to "API_URL" and append "/v2"

Eg:- https://api-yourprefix.domain.com/v2


---

## `env-set`

**Description:**
Writes a value to an environment file. Does not create Kubernetes secret
Use env-write if you want to create Kubernetes secret

**Parameters:**
- `$1`: Value to write

**Usage:**
```sh
env-set ''
```

**Example:**
```sh
env-set '
              - name: LOG_PATH
                value: /
              - name: LOG_LEVEL
                value: DEBUG          
              - name: PREDICTION_SERVER
                value: SELDON_CORE
              - name: NAMESPACE
                value: my-namespace                                                            

'
```

---

## `env-write`

**Description:**
Writes the environment configuration and stores it as a Kubernetes secret if necessary.
Required to create kubernetes secrets

**Parameters:**
- `$1`: Value to write

**Usage:**
```sh
env-write ''
```

**Example:**
```sh
env-write '
              - name: LOG_PATH
                value: /
              - name: LOG_LEVEL
                value: DEBUG          
              - name: PREDICTION_SERVER
                value: SELDON_CORE
              - name: NAMESPACE
                value: my-namespace                                                            

'
```

---


## `env-write-config-map` is Deprecated use env-add-config-map

## `env-add-config-map`
**Description:**
Rewrites a Kubernetes ConfigMap configuration file by substituting environment variables. This function is typically used in deployment pipelines to dynamically inject environment-specific values into configuration templates.

**Parameters:**
| Parameter | Description                                                                 |
|-----------|-----------------------------------------------------------------------------|
| `$1`      | Name of the ConfigMap file (without extension) located in `CC_RESOURCES_ROOT` |
| `$@`      | Environment variable names to substitute (e.g., `DB_HOST API_KEY`)            |


**Usage:**
```sh
env-add-config-map <config_name> [VAR1 VAR2 ...]
```

**Example:**  
```sh
# Export required environment variables
# To get the fully qualified domain name with subdomains defined in SD_UI SD_PAY SD_API
export SD_UI_FQN=$(fqhn "${SD_UI}")
export SD_PAY_FQN=$(fqhn "${SD_PAY}")
export SD_API_FQN=$(fqhn "${SD_API}")


# Process template with environment variables
env-add-config-map "${1}" "SD_UI_FQN" "SD_PAY_FQN" "SD_API_FQN"

#or

env-add-config-map "myapp-config" "SD_UI_FQN" "SD_PAY_FQN" "SD_API_FQN"
#myapp-config.configmap file should exist in CC_RESOURCES_ROOT folder

```


** Sample File**  myapp-config.configmap 
```yaml
######################## env.js ConfigMap ####################
apiVersion: v1
kind: ConfigMap
metadata:
  name: myenv
  namespace: my-namespace
data:
  env.js: |-
    (function (window) {
      window.__env = window.__env || {};
      // Your REST API urls
      window.__env.webBaseUrl = 'https://${SD_UI_FQN}';
      window.__env.payUrl = 'https://${SD_PAY_FQN}';
      window.__env.apiUrl = 'https://${SD_API_FQN}';

    }(this));      

```

---

## `env-append-host-mapping`

**Description:**
Appends a host mapping to the environment.

**Parameters:**
- `$1`: Host mapping

**Usage:**
```sh
env-append-host-mapping '
  add_request_headers:
    X-ProxyPort:
      value: "443"
    X-ProxyScheme:
      value: https
'
```

---

## `fqhn`

**Description:** Generates a fully qualified hostname.

**Parameters:**

- `$1`: Subdomain.

**Usage:**

```sh
fqhn "subdomain"
```

**Example:**

```sh
env-add "https://$(fqhn ${SD_API})" "API_URL"
```

---

## `fqn`

**Description:** Generates a fully qualified name using `CC_SUB_DOMAIN_SUFFIX`.

**Parameters:**

- `$1`: Application name (optional).

**Usage:**

```sh
env-add "$(fqn)" "SUB_DOMAIN"
```

---




