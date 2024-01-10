source zlink.sh

export CC_MODE=live

#### Create nodepools ######################
# ./az/aks-np.sh -p "nplb" -m "Standard_DS2_v2" -d "30"
# ./az/aks-np.sh -p "npdata" -m "Standard_DS2_v2" -d "120"
# ./az/aks-np.sh -p "npqueue" -m "Standard_DS2_v2" -d "60"

# Customize the creation with -o options

# to use 3 availability zone add to options --zones 1 2 3
# ./az/aks-np.sh -o "--node-count 1 --min-count 1 --max-count 8 --max-pods 250 --enable-cluster-autoscaler --zones 1 2 3"



#### Helm Deployments #######################
#### Provide path of your helm charts in az-overrides.env
#source helm/init.sh

# ./helm/rabbitmq.sh.sh -p "npqueue" -s "nsqueue" -a "install"
# ./az/helm/emissary-ingress.sh -p "nplb" -s "nslb" -a "install"
# ./az/helm/minio.sh -p "npdata" -s "nsdata" -a "install"

# ./helm/mariadb-galera.sh -p "npdata" -s "nsdata" -a "install"



source az/aks-use.sh


#### Upgrade nodepool
# ./az/aks-np-update.sh -p "nplb" -o "--min-count 2 --max-count 4 --update-cluster-autoscaler"


