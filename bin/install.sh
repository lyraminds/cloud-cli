

TAG=${1:-main}
echo "tag version ${TAG}"

git clone --depth 1 --branch ${TAG} https://github.com/LyraOps/cloud-cli.git cloud-cli

