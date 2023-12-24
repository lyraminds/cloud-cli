#!/bin/bash

NS=$1
source bin/base.sh

rlog "kubectl delete namespace $NS"

empty $1 "Namespace"


C="kubectl create namespace $NS"
ok && run-cmd "$C" 

run-sleep 1 
