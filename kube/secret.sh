
SECRET=${1:-default-secret}
NS=${2:-default}
SECRET_FILES=${3:-$CC_GEN_SECRET_FILES}

source bin/base.sh

H="
kube/secret.sh \"secrent-name\" \"mynamespace\" \"--from-file=/secret/minio/root-user --from-file=/secret/minio/root-password\"
"
empty $1 "Secret Name" "${H}"
empty $2 "Namespace" "${H}"
empty $3 "Secret files" "${H}"

C="kubectl create secret generic $SECRET --save-config --dry-run=client --namespace=$NS ${SECRET_FILES} -o yaml | kubectl apply -f -"
run-cmd "$C"

