

SIZE=${1:-20}
RES=${2:-standardDSv2Family}
SUB=${CC_SUBSCRIPTION}
source bin/base.sh
#az account clear
H="
./quota-update.sh \"${SIZE}\" \"${RES}\"
./quota-update.sh \"size\" \"resource-name\" 
"

help "$1" "$H"

empty "${SIZE}" "Quota Size" "$H"
empty "${RES}" "Resource name family" "$H"

CUR_SIZE=`az quota show --resource-name ${RES} --scope /subscriptions/${SUB}/providers/Microsoft.Compute/locations/${CC_REGION} --query "[properties.limit.value]" -o tsv`
DI="Current Size = ${CUR_SIZE} 
Requested Size = ${SIZE}"
log "${DI}"
if [ "${CUR_SIZE}" != "${SIZE}" ]; then
echo "${DI}"
C="az quota update --resource-name ${RES} --scope /subscriptions/${SUB}/providers/Microsoft.Compute/locations/${CC_REGION} --limit-object value=${SIZE} --resource-type dedicated"
run-cmd "${C}"


echo "Wait for some time..."
run-sleep "3"
else
log "Ignoring quota update..."
fi
