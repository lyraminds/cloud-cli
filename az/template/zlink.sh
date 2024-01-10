
CFOLDER=`pwd`

#Going back to folder outside cloud-cli
# cd ../../../../
cd /opt/

##install cli if missing

if [ -d "cloud-cli" ]; then
echo "..."
else
echo "cloud-cli not found..."
bash -c "$(curl -L https://raw.githubusercontent.com/lyraminds/cloud-cli/main/bin/install.sh)"
echo "Visit https://github.com/lyraminds/cloud-cli"
fi

cd cloud-cli
echo `cat doc/version.txt`
#Using defaults
source conf/default-azure.env

#To change root of log folder 
export CC_LOG_ROOT=${CFOLDER}

#Link your config file
source ${CFOLDER}/az.env
source ${CFOLDER}/az-overrides.env

#Initializing with your configs
source bin/init.sh

source helm/init.sh