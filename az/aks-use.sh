#!/bin/bash

KS=${1:-$CC_AKS_CLUSTER_NAME}
RG=${2:-$CC_RESOURCE_GROUP_NAME}

source bin/base.sh

info "az aks get-credentials -g $RG --name $KS --admin"
ok && az aks get-credentials -g $RG --name $KS --admin

info "kubectl cluster-info"
ok && kubectl cluster-info

info "az aks nodepool list --cluster-name ${KS} -g $RG -o table"
ok && az aks nodepool list --cluster-name ${KS} -g $RG -o table
