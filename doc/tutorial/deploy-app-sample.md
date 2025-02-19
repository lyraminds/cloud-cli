## How To deploy application

**Create env-vars.sh** See here


**Create deploy-app.sh** 

Master file for all deployment to Azure AKS

```sh
source zlink.sh
source ${CC_RUN}/env-vars.sh
export CC_MODE=live
source az/init.sh
source az/aks-use.sh

## Kubernetics commants to execute
#ACTION="apply|create|replace|delete"
ACTION="apply"
# ACTION="delete"

## Version of your application
VERSION="1.0"

## Overide the generate file true will always overwrite your locally generated file
OVER_WRITE="true"


```

**Create Service links to link base applications**

To link your database and message queue in you api application
```sh
./kube/service-link.sh -a "${ACTION}" -s "ns-ui" -n "mariadb-galera"
./kube/service-link.sh -a "${ACTION}" -s "ns-ui" -n "rabbitmq"
```

**Deploy a front end UI**

```sh

## env-app-ui should be defined in env-vars.sh
env-app-ui "my-app-ui" "ns-ui" "80" "${SD_UI}"

## Generate deployment yaml and deploys to your given namespace
## To view the help use ./kube/service.sh -h
./kube/service.sh -n "my-app-ui" -s "ns-ui" -c "80" -e "${SD_UI}" -p "npui" -a "${ACTION}" -v "${VERSION}" -w "${OVER_WRITE}"

```

----

**Deploy a backend API**

```sh
env-app-api "my-app-api" "ns-api" "7000" "${SD_API}"
./kube/service.sh -n "my-app-api" -s "ns-api" -c "7000" -e "${SD_API}" -p "npapi" -a "${ACTION}" -v "${VERSION}" -w "${OVER_WRITE}"
```

---

## Reference

[env-vars](/doc/env-vars.md)

## Sample

[env-vars](/doc/tutorial/env-vars-sample.md)