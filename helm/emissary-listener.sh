#!/bin/bash

APP_NAME=${1}
NS=${2}
#BEHIND_L7, L7
LB=${3:-BEHIND_L7}


source bin/base.sh

OVR="${CC_BASE_DEPLOY_FOLDER}/${APP_NAME}-listener.yaml"

if [ ${LB} = BEHIND_L7 ]; then

echo "
apiVersion: getambassador.io/v3alpha1
kind: Listener
metadata:
  name: \"${APP_NAME}-http\"
  namespace: \"${NS}\"
spec:
  port: 8080
  protocol: HTTP
  securityModel: XFP
  l7Depth: 1
  hostBinding:     # This may well need editing for your case!
    namespace:
      from: ALL
---
apiVersion: getambassador.io/v3alpha1
kind: Listener
metadata:
  name: \"${APP_NAME}-https\"
  namespace: \"${NS}\"
spec:
  port: 8443
  protocol: HTTPS
  securityModel: XFP
  l7Depth: 1
  hostBinding:     # This may well need editing for your case!
    namespace:
      from: ALL
" > $OVR
else
echo "
apiVersion: getambassador.io/v3alpha1
kind: Listener
metadata:
  name: \"${APP_NAME}-l7-https\"
  namespace: \"${NS}\"
spec:
  port: 8443
  protocol: HTTPS
  securityModel: XFP
  hostBinding:
    namespace:
      from: ALL
---
apiVersion: getambassador.io/v3alpha1
kind: Listener
metadata:
  name: \"${APP_NAME}-l7-http\"
  namespace: \"${NS}\"
spec:
  port: 8080
  protocol: HTTP
  securityModel: XFP
  hostBinding:
    namespace:
      from: ALL
" > $OVR
fi

run-cmd "kubectl apply -f ${OVR}"
