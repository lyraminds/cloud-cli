#!/bin/bash

TAINT_VALUE=${1}
OVR=${2}
TAB=${3:-TAB0}
TAINT_TYPE=${CC_NODE_POOL_TAINT_TYPE}
TAINT_EFFECT=${CC_NODE_POOL_TAINT_EFFECT}

source bin/base.sh

if [ ${TAB} = TAB1 ]; then
echo "
  tolerations:
    - key: \"${TAINT_TYPE}\"
      operator: \"Equal\"
      value: \"${TAINT_VALUE}\"
      effect: \"${TAINT_EFFECT}\"

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: \"agentpool\"
            operator: \"In\"
            values:
            - \"${TAINT_VALUE}\"
" >> $OVR
elif [ ${TAB} = TAB2 ]; then
echo "
    tolerations:
      - key: \"${TAINT_TYPE}\"
        operator: \"Equal\"
        value: \"${TAINT_VALUE}\"
        effect: \"${TAINT_EFFECT}\"

    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: \"agentpool\"
              operator: \"In\"
              values:
              - \"${TAINT_VALUE}\"
" >> $OVR
elif [ ${TAB} = TAB3 ]; then
echo "
      tolerations:
        - key: \"${TAINT_TYPE}\"
          operator: \"Equal\"
          value: \"${TAINT_VALUE}\"
          effect: \"${TAINT_EFFECT}\"

      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: \"agentpool\"
                operator: \"In\"
                values:
                - \"${TAINT_VALUE}\"
" >> $OVR
elif [ ${TAB} = TAB4 ]; then
echo "
        tolerations:
          - key: \"${TAINT_TYPE}\"
            operator: \"Equal\"
            value: \"${TAINT_VALUE}\"
            effect: \"${TAINT_EFFECT}\"

        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: \"agentpool\"
                  operator: \"In\"
                  values:
                  - \"${TAINT_VALUE}\"
" >> $OVR
else 
echo "

tolerations:
  - key: \"${TAINT_TYPE}\"
    operator: \"Equal\"
    value: \"${TAINT_VALUE}\"
    effect: \"${TAINT_EFFECT}\"

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: \"agentpool\"
          operator: \"In\"
          values:
          - \"${TAINT_VALUE}\"
" >> $OVR

fi