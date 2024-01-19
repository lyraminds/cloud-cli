
source bin/base.sh


if [ $(installed "helm") == "false" ]; then
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

if [ ! -d "${CC_HELM_CHARTS_ROOT}" ]; then
error "No helm root folders found at [${CC_HELM_CHARTS_ROOT}], define right path at [CC_HELM_CHARTS_ROOT] in xx-overrides.env"
exit;
fi