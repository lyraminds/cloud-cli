#!/bin/bash
APP_NAME=${1}
NS=${2}
SERVICE=${3}
SUB_DOMAIN=${4}
#BEHIND_L7, L7
OVR_FOLDER=${5:-"${CC_BASE_DEPLOY_FOLDER}"}
ACTION=${6:-"apply"}
LB=${7:-"BEHIND_L7"}

source bin/base.sh



HNAME="$(fqhn $SUB_DOMAIN)"

DPF="${OVR_FOLDER}/${NS}"
mkdir -p "${DPF}"
OVR="${DPF}/${APP_NAME}-host-mapping.yaml"

if [ "${LB}" == "BEHIND_L7" ]; then

echo "
apiVersion: getambassador.io/v3alpha1
kind: Host
metadata:
  name: \"${APP_NAME}-host\"
  namespace: \"${NS}\"
spec:
  hostname: \"${HNAME}\"
  requestPolicy:
    insecure:
      action: Redirect
---
apiVersion: getambassador.io/v3alpha1
kind:  Mapping
metadata:
  name:  \"${APP_NAME}-mapping\"
  namespace: \"${NS}\"
spec:
  host: \"${HNAME}\"
  prefix: /
  service: \"${SERVICE}\"
  timeout_ms: 0
  envoy_override:
    per_connection_buffer_limit_bytes: 2000000000


" > ${OVR}
else
echo "
apiVersion: getambassador.io/v3alpha1
kind: Host
metadata:
  name: \"${APP_NAME}-host\"
  namespace: \"${NS}\"
spec:
  hostname: \"${HNAME}\"
  # requestPolicy:
  #   insecure:
  #     action: Redirect
  acmeProvider:
    authority: none
  tlsSecret:
    name: wildcard-${APP_NAME}-${DOMAIN_NAME}
---
apiVersion: getambassador.io/v3alpha1
kind:  Mapping
metadata:
  name:  \"${APP_NAME}-mapping\"
  namespace: \"${NS}\"
spec:
  host: \"${HNAME}\"
  prefix: /
  service: \"${SERVICE}\"
  timeout_ms: 0
  envoy_override:
    per_connection_buffer_limit_bytes: 2000000000
---
" > ${OVR}
fi

if [ "${ACTION}" == "delete" ]; then
run-cmd "kubectl -n ${NS} delete mapping ${APP_NAME}-mapping"
# run-sleep "1" 
else
run-cmd "kubectl apply -f ${OVR}"
fi