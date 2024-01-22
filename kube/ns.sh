#!/bin/bash

NS=${1}
source bin/base.sh

empty ${NS} "Namespace"

E=$(kubectl get namespace "${NS}" --no-headers --output=go-template="{{.metadata.name}}" 2>/dev/null)
  if [[ -z ${E} ]];then
C="kubectl create namespace ${NS} --dry-run=client -o yaml | kubectl apply -f -"
run-cmd "${C}" 
run-sleep 1
  fi


