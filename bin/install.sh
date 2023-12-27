

TAG=${1:-main}
echo "tag version ${TAG}"
mkdir /opt
cd /opt
git clone --depth 1 --branch ${TAG} https://github.com/lyraminds/cloud-cli.git cloud-cli

sudo rm /usr/bin/az-onboard

sudo ln -s /opt/cloud-cli/az/onboard.sh /usr/bin/az-onboard
