#!/bin/bash

TAINT_VALUE=${1}
OVR=${2}
TAB=${3:-TAB0}
POD_ANTI_AFFINITY_WEIGHT=${4}
MY_ENV=${CC_CUSTOMER_ENV}
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

if [ ! -z "${POD_ANTI_AFFINITY_WEIGHT}" -a "${POD_ANTI_AFFINITY_WEIGHT}" != "" ]; then
echo "
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: ${POD_ANTI_AFFINITY_WEIGHT}
        podAffinityTerm:
          labelSelector:
            matchLabels:
              env: ${MY_ENV}
          topologyKey: "kubernetes.io/hostname"
" >> $OVR
fi

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

if [ ! -z "${POD_ANTI_AFFINITY_WEIGHT}" -a "${POD_ANTI_AFFINITY_WEIGHT}" != "" ]; then
echo "
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: ${POD_ANTI_AFFINITY_WEIGHT}
          podAffinityTerm:
            labelSelector:
              matchLabels:
                env: ${MY_ENV}
            topologyKey: "kubernetes.io/hostname"
" >> $OVR
fi

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

if [ ! -z "${POD_ANTI_AFFINITY_WEIGHT}" -a "${POD_ANTI_AFFINITY_WEIGHT}" != "" ]; then
echo "
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: ${POD_ANTI_AFFINITY_WEIGHT}
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  env: ${MY_ENV}
              topologyKey: "kubernetes.io/hostname"
" >> $OVR
fi

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

if [ ! -z "${POD_ANTI_AFFINITY_WEIGHT}" -a "${POD_ANTI_AFFINITY_WEIGHT}" != "" ]; then
echo "
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - weight: ${POD_ANTI_AFFINITY_WEIGHT}
              podAffinityTerm:
                labelSelector:
                  matchLabels:
                    env: ${MY_ENV}
                topologyKey: "kubernetes.io/hostname"
" >> $OVR
fi

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


if [ ! -z "${POD_ANTI_AFFINITY_WEIGHT}" -a "${POD_ANTI_AFFINITY_WEIGHT}" != "" ]; then
echo "
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: ${POD_ANTI_AFFINITY_WEIGHT}
      podAffinityTerm:
        labelSelector:
          matchLabels:
            env: ${MY_ENV}
        topologyKey: "kubernetes.io/hostname"
" >> $OVR
fi

fi