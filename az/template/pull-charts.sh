source zlink.sh

export CC_MODE=live


#### Helm Deployments #######################
#### Provide path of your helm charts in az-overrides.env
source helm/init.sh

#### Download required charts to CC_HELM_CHARTS_ROOT folder
helm-pull "https://grafana.github.io/helm-charts" "grafana" "grafana" "7.0.16"

helm-pull "https://prometheus-community.github.io/helm-charts" "prometheus-community" "prometheus" "25.7.0"
helm-pull "https://prometheus-community.github.io/helm-charts" "prometheus-community" "prometheus-blackbox-exporter" "8.5.0"
helm-pull "https://prometheus-community.github.io/helm-charts" "prometheus-community" "prometheus-mysql-exporter" "2.2.0"
helm-pull "https://prometheus-community.github.io/helm-charts" "prometheus-community" "alertmanager" "1.7.0"

helm-pull "https://helm.elastic.co" "elastic" "kibana" "7.17.3"
helm-pull "https://helm.elastic.co" "elastic" "filebeat" "8.5.1"
helm-pull "https://helm.elastic.co" "elastic" "elasticsearch" "8.5.1"


