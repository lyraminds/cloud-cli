#!/bin/bash

NS=$1
source bin/base.sh

empty $1 "Namespace"

C="kubectl create namespace $NS --dry-run=client -o yaml | kubectl apply -f -"
ok && run-cmd "$C" 
run-sleep 1
