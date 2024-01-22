source zlink.sh

export CC_MODE=live


#### Helm Deployments #######################
#### Provide path of your helm charts in az-overrides.env
source helm/init.sh
source az/aks-use.sh

#### Download required charts to CC_HELM_CHARTS_ROOT folder defined in  az-overrides.env
#### Optional if your charts are already available in CC_HELM_CHARTS_ROOT folder


#### Helm install/upgrade/uninstall ####################################

# helm-install "grafana" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/grafana" "${CONFIG_ROOT}/grafana/values.yaml" 
# helm-install "elasticsearch" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/elasticsearch" "${CONFIG_ROOT}/elasticsearch/values.yaml" 
# helm-install "prometheus" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus" "${CONFIG_ROOT}/prometheus/values.yaml" 
# helm-install "prometheus-blackbox-exporter " "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-blackbox-exporter " "${CONFIG_ROOT}/prometheus-blackbox-exporter/values.yaml" 
# helm-install "prometheus-mysql-exporter" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-mysql-exporter" "${CONFIG_ROOT}/prometheus-mysql-exporter/values.yaml" 
# helm-install "alertmanager" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/alertmanager" "${CONFIG_ROOT}/alertmanager/values.yaml" 
# helm-install "kibana" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/kibana" "${CONFIG_ROOT}/kibana/values.yaml" 
# helm-install "filebeat" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/filebeat" "${CONFIG_ROOT}/filebeat/values.yaml" 



# ./az/helm/emissary-ingress.sh -p "nplb" -a "install"
# ./az/helm/istio.sh -p "npistio" -a "install"
# ./az/kube/istio-gateway.sh -d "seldon" -a "install"
# ./az/helm/minio.sh -p "npdata" -s "nsdata" -a "delete"
# ./helm/mariadb-galera.sh -p "npdata" -s "nsdata" -a "delete"
# ./az/helm/rabbitmq.sh -p "npdata" -s "nsdata" -a "install"



# ./kube/purge-all.sh -s "nsdata"


