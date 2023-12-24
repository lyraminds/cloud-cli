

TAG=${1:-main}
echo "tag version ${TAG}"

git clone --depth 1 --branch ${TAG} https://github.com/lyraminds/cloud-cli.git cloud-cli

