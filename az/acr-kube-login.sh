#!/bin/bash

source bin/base.sh


az aks get-credentials -g $RG -n $AKSNAME --admin

$ACR_UNAME=$(az acr credential show -n $ACR_FULL_NAME --query="username" -o tsv)
$ACR_PASSWD=$(az acr credential show -n $ACR_FULL_NAME --query="passwords[0].value" -o tsv)

# Create k8s secret
kubectl create secret docker-registry acr-secret `
  --docker-server=$ACR_FULL_NAME `
  --docker-username=$ACR_UNAME `
  --docker-password=$ACR_PASSWD

# Assign k8s secret to default service account
kubectl patch serviceaccount default -p '{\"imagePullSecrets\": [{\"name\": \"acr-secret\"}]}'

