#!/bin/bash

KS=${1:-$CC_AKS_CLUSTER_NAME}
RG=${2:-$CC_RESOURCE_GROUP_NAME}

source base.sh

ok 

vlog "az aks get-credentials -g $RG --name $KS --admin"
az aks get-credentials -g $RG --name $KS --admin

ok 

vlog "kubectl cluster-info"
kubectl cluster-info

ok 

vlog "az aks nodepool list --cluster-name ${KS} -g $RG -o table"
az aks nodepool list --cluster-name ${KS} -g $RG -o table
