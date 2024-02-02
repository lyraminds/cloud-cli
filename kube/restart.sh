#!/bin/bash

NS=${1}
APP_NAME=${2}
source bin/base.sh

empty ${NS} "Namespace"
empty ${APP_NAME} "APP NAME"

run-cmd "kubectl -n ${NS} rollout restart deployment.apps/${APP_NAME}"