
#!/bin/bash
NS=""
ACTION="install"

#==============================================
source bin/base.sh
H="
./kube/purge-all.sh -s "name-space" 

"

help "${1}" "${H}"

while getopts s: flag
do
info "kube/purge-all.sh ${flag} ${OPTARG}"
    case "${flag}" in
        s) NS=${OPTARG};;
    esac
done

empty "$NS" "NAMESPACE" "$H"

echo "
###################### IMPORTANT WARNING: #########################
This will wipe out your entire pod, pvc, pv under namespace [${NS}]
"
read -p "Are you sure to delete all pod, pvc and pv  (y/n):" YN

#Print output based on the input

if [ "$YN" == "y" ]; then
C="kubectl -n ${NS} delete pod --all"
run-cmd "${C}"
C="kubectl -n ${NS} delete pvc --all"
run-cmd "${C}"
C="kubectl -n ${NS} delete pv --all"
run-cmd "${C}"
fi