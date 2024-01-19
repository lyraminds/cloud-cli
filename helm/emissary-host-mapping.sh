#!/bin/bash
APP_NAME=${1}
NS=${2}
SERVICE=${3}
SUB_DOMAIN=${4:-$APP_NAME}
#BEHIND_L7, L7
LB=${5:-BEHIND_L7}

source bin/base.sh

HNAME="$(fqhn $SUB_DOMAIN)"

OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-host-mapping.yaml"
if [ ${LB} = BEHIND_L7 ]; then

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


" > $OVR
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
" > $OVR
fi

# run-cmd "kubectl delete -f ${OVR}"
# run-sleep "1" 
run-cmd "kubectl apply -f ${OVR}"
