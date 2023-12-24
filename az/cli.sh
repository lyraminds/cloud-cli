

source bin/base.sh


if [ $(installed "az") == "false" ]; then

nlog "#Azure CLI"
 
  if [ "$CC_OS" == "ubuntu" ]; then    
    run-cmd "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
  else 
    run-cmd "curl -L https://aka.ms/InstallAzureCli | bash"
  fi

run-cmd "az upgrade"

run-cmd "az extension add --name front-door"
vlog "az extension list-available --output table"
else
 info "Azure CLI found"
 az --version
fi

