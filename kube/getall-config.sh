#!/bin/bash
NS=${1:default}

source bin/base.sh

empty ${NS} "Namespace"

P="${CC_LOG_FOLDER}/download/config"
mkdir -p "${P}"
echo "Config from server will be saved at ${P}"
for n in $(kubectl get -n ${NS} -o=name pvc,configmap,serviceaccount,secret,ingress,service,deployment,statefulset,hpa,job,cronjob)
do

    echo "$(dirname $n)"
    echo "${n}"
    kubectl  -n ${NS} get $n -o yaml > ${P}/$(dirname $n)_$(basename $n).yaml
done
