
source bin/base.sh

if [ $(installed "gpg") == "false" ]; then
run-install "gpg"
fi

if [ ! -f "/usr/share/keyrings/hashicorp-archive-keyring.gpg" ]; then
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
fi

if [ $(installed "helm") == "false" ]; then
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

if [ ! -d "${CC_HELM_CHARTS_ROOT}" ]; then

echo "
###################### NO LOCAL HELM ROOT FOLDER FOUND: #########################
No folders exist at [${CC_HELM_CHARTS_ROOT}], define right path at [CC_HELM_CHARTS_ROOT] in xx-overrides.env
Or 
Create a new folder 
"
read -p "Are you sure to create a new folder at [${CC_HELM_CHARTS_ROOT}] (y/n):" YN

#Print output based on the input

if [ "$YN" == "y" ]; then
C="mkdir -p ${CC_HELM_CHARTS_ROOT}"
run-cmd "${C}"
else
echo "To Continue, create [${CC_HELM_CHARTS_ROOT}] folder, or change path at [CC_HELM_CHARTS_ROOT] in xx-overrides.env"
exit;
fi

fi