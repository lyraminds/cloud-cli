

TAG=${1:-main}


setup-cloud-cli(){
sudo git clone --depth 1 --branch ${TAG} https://github.com/lyraminds/cloud-cli.git cloud-cli

if [ -f "/usr/bin/az-onboard" ]; then
sudo rm /usr/bin/az-onboard
fi
sudo ln -s /opt/cloud-cli/az/onboard.sh /usr/bin/az-onboard

cd cloud-cli
IV=`cat doc/version.txt`

echo "
Successfully installed ${IV}
"

}

# set -e

# echo "tag version ${TAG}"
mkdir -p /opt
cd /opt

if [ -d "cloud-cli" ]; then
cd cloud-cli
IV=`cat doc/version.txt`


LV=$(curl -sS -L https://raw.githubusercontent.com/lyraminds/cloud-cli/main/doc/version.txt)

EXITCODE=$?
if [ ${EXITCODE} -ne 0 ]; then
  exit ${EXITCODE};
fi


if [ "${IV}" == "${LV}" ]; then
echo "
You have latest version of [${LV}]
"
else

echo "
###################### New Version ia available #########################
Your version is ${IV}
"
read -p "Are you sure to upgrade to [${LV}] (y/n):" YN

#Print output based on the input

if [ "$YN" == "y" ]; then

cd ..
echo "
Backing up current version to /opt/${IV}-bkp
"
sudo mv /opt/cloud-cli "/opt/${IV}-bkp"

echo "
Upgrading cloud-cli from [${IV}] to [${LV}] ...
"
setup-cloud-cli
else
echo "

Skipping upgrade, To install latest version manually delete '/opt/cloud-cli' folder and install
      
      sudo rm -rf /opt/cloud-cli
      
      "
exit;
fi


fi


else
echo "cloud-cli not found..."
setup-cloud-cli
fi


