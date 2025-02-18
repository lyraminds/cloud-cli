# Documentation for Deploy base Script Functions

## `run-helm`

**Description:** Executes Helm commands such as install, upgrade, delete, or uninstall. Using custom helm file

**Parameters:**

- `$1`: Action (`install`, `upgrade`, `delete`, or `uninstall`).
- `$2`: Application name.
- `$3`: Kubernetes namespace.
- `$4`: Chart path (for install/upgrade).
- `$5`: Overrides file (optional).

**Usage:**

```sh
run-helm "install" "myapp" "namespace" "/path/to/chart" "values.yaml"
```

**Example:** Example to get the helmcharts and install based on your overriede value file

```sh

ACTION="install"
# Root folder of your custom helm override value files
# Using CC_RESOURCES_ROOT and CC_HELM_CHARTS_ROOT make sure your resources are part of the cli workspace.
CONFIG_ROOT=${CC_RESOURCES_ROOT}/deploy/ce-analytics



run-helm "${ACTION}" "grafana" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/grafana" "${CONFIG_ROOT}/grafana/values.yaml" 

run-helm "${ACTION}" "elasticsearch" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/elasticsearch" "${CONFIG_ROOT}/elasticsearch/values.yaml" 

run-helm "${ACTION}" "prometheus" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus" "${CONFIG_ROOT}/prometheus/values.yaml" 

run-helm "${ACTION}" "prometheus-blackbox-exporter " "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-blackbox-exporter " "${CONFIG_ROOT}/prometheus-blackbox-exporter/values.yaml" 

run-helm "${ACTION}" "prometheus-mysql-exporter" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/prometheus-mysql-exporter" "${CONFIG_ROOT}/prometheus-mysql-exporter/values.yaml" 

run-helm "${ACTION}" "alertmanager" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/alertmanager" "${CONFIG_ROOT}/alertmanager/values.yaml" 

run-helm "${ACTION}" "kibana" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/kibana" "${CONFIG_ROOT}/kibana/values.yaml" 

run-helm "${ACTION}" "filebeat" "nsmonitor" "${CC_HELM_CHARTS_ROOT}/filebeat" "${CONFIG_ROOT}/filebeat/values.yaml" 

```

---
