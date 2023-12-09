
CFOLDER=`pwd`

#Going back to folder outside cloud-cli
cd ../../../../

##install cli if missing

if [ -d "cloud-cli" ]; then
echo "cloud-cli found..."
else
echo "cloud-cli not found..."
# git clone --depth 1 https://github.com/arunvc/cloud-cli cloud-cli
fi

#Using defaults
source cloud-cli/conf/default-azure.env

#To change root of log folder 
export CC_LOG_ROOT=${CFOLDER}

#Link your config file
source accounts/private-azure.env

#Initializing with your configs
source cloud-cli/init.sh