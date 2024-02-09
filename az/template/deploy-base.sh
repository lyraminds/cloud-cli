source zlink.sh

export CC_MODE=live
source az/init.sh
source az/aks-use.sh
source ${CC_RUN}/build-charts.sh
#### Download required charts to CC_HELM_CHARTS_ROOT folder defined in  az-overrides.env or via build-charts.sh
### Helm deployments dynamically create override files based on customer & env #################


### ACTION = install/upgrade/uninstall
ACTION="install"
VERSION="1.0"


# ./az/helm/emissary-ingress.sh -p "nplb" -a "${ACTION}"
# ./az/helm/istio.sh -p "npistio" -a "${ACTION}"
# ./az/kube/istio-gateway.sh -a "${ACTION}" -e "seldon" 

# ./az/helm/minio.sh -p "npdata" -s "nsdata" -a "${ACTION}" -e "storage"
# ./helm/mariadb-galera.sh -p "npdata" -s "nsdata" -a "${ACTION}"
# ./helm/nifi-registry.sh -p "nplb" -s "nslb" -a "${ACTION}"
# ./az/helm/rabbitmq.sh -p "npdata" -s "nsdata" -a "${ACTION}" -e "queue"
# ./helm/seldon-operator.sh -p "nplb" -s "nslb" -a "${ACTION}" -v "${VERSION}"

###Build custom theme image
#  build-keycloak-theme
# ./az/helm/keycloak.sh -p "npdata" -s "nsdata" -a "${ACTION}" -e "auth" -t "ce-keycloak" -v "${VERSION}"


CONFIG_ROOT=${CC_RESOURCES_ROOT}/deploy/ce-analytics

#### Helm deploy your own override value file

#run-helm "${ACTION}" "grafana" "nsdata" "${CC_HELM_CHARTS_ROOT}/grafana" "${CONFIG_ROOT}/grafana/values.yaml" 
# run-helm "${ACTION}" "elasticsearch" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/elasticsearch" "${CONFIG_ROOT}/elasticsearch/values.yaml" 
# run-helm "${ACTION}" "prometheus" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus" "${CONFIG_ROOT}/prometheus/values.yaml" 
# run-helm "${ACTION}" "prometheus-blackbox-exporter " "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-blackbox-exporter " "${CONFIG_ROOT}/prometheus-blackbox-exporter/values.yaml" 
# run-helm "${ACTION}" "prometheus-mysql-exporter" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-mysql-exporter" "${CONFIG_ROOT}/prometheus-mysql-exporter/values.yaml" 
# run-helm "${ACTION}" "alertmanager" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/alertmanager" "${CONFIG_ROOT}/alertmanager/values.yaml" 
# run-helm "${ACTION}" "kibana" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/kibana" "${CONFIG_ROOT}/kibana/values.yaml" 
# run-helm "${ACTION}" "filebeat" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/filebeat" "${CONFIG_ROOT}/filebeat/values.yaml" 









# ./kube/service-uninstall.sh "nsdata" "ce-keycloak"
# ./kube/purge-all.sh -s "nsdata"
