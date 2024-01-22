source zlink.sh
export CC_MODE=live
source helm/init.sh
source az/aks-use.sh

#### Helm Deployments #######################
#### Provide path of your helm charts in CC_HELM_CHARTS_ROOT variable in az-overrides.env
#### Download required charts to CC_HELM_CHARTS_ROOT folder

### Ingress setup
### To see the full option use -h
##./az/helm/emissary-ingress.sh -h
## -a options are install|upgrade|delete

# ./az/helm/emissary-ingress.sh -p "nplb" -a "install"
# ./az/helm/istio.sh -p "npistio" -a "install"
# ./az/kube/istio-gateway.sh -d "seldon" -a "install"


### Other applications

# ./az/helm/minio.sh -p "npdata" -s "nsdata" -a "install"
# ./az/helm/rabbitmq.sh -p "npdata" -s "nsdata" -a "install"
# ./helm/mariadb-galera.sh -p "npdata" -s "nsdata" -a "install"






#### Helm install/upgrade/uninstall ####################################

# run-helm "install" "grafana" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/grafana" "${CONFIG_ROOT}/grafana/values.yaml" 
# run-helm "install" "elasticsearch" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/elasticsearch" "${CONFIG_ROOT}/elasticsearch/values.yaml" 
# run-helm "install" "prometheus" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus" "${CONFIG_ROOT}/prometheus/values.yaml" 
# run-helm "install" "prometheus-blackbox-exporter " "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-blackbox-exporter " "${CONFIG_ROOT}/prometheus-blackbox-exporter/values.yaml" 
# run-helm "install" "prometheus-mysql-exporter" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-mysql-exporter" "${CONFIG_ROOT}/prometheus-mysql-exporter/values.yaml" 
# run-helm "install" "alertmanager" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/alertmanager" "${CONFIG_ROOT}/alertmanager/values.yaml" 
# run-helm "install" "kibana" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/kibana" "${CONFIG_ROOT}/kibana/values.yaml" 
# run-helm "install" "filebeat" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/filebeat" "${CONFIG_ROOT}/filebeat/values.yaml" 