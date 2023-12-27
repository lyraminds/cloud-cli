

TAG=${1:-main}
set -e

echo "tag version ${TAG}"
mkdir -p /opt
cd /opt

if [ -d "cloud-cli" ]; then
cd cloud-cli
echo `cat doc/version.txt`
echo "To install latest version delete '/opt/cloud-cli' folder
      sudo rm -rf /opt/cloud-cli"
else
echo "cloud-cli not found..."
git clone --depth 1 --branch ${TAG} https://github.com/lyraminds/cloud-cli.git cloud-cli

if [ -f "/usr/bin/az-onboard" ]; then
sudo rm /usr/bin/az-onboard
fi
sudo ln -s /opt/cloud-cli/az/onboard.sh /usr/bin/az-onboard

fi


