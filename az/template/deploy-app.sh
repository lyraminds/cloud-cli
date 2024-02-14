source zlink.sh
source ${CC_RUN}/env-vars.sh

export CC_MODE=live
source az/init.sh
source az/aks-use.sh



############################### BUILD AND DEPLOY AREA #################################################

### Build All will build respective docker images defined in build-docker.sh
# ACTION="apply|create|replace|delete"
# ACTION="delete"
ACTION="apply"
VERSION="1.0"

# echo "################################ Deploy Microsoft OCR"
# ./kube/microsoft-ocr.sh -n "computer-vision-read-ocr1" -s "nsdata" -e "ocr1" -p "npdata"  -u "mcr.microsoft.com/azure-cognitive-services/vision/read:3.2" -r "2" -a "${ACTION}"
# ./kube/microsoft-ocr.sh -n "computer-vision-read-ocr2" -s "nsdata" -e "ocr2" -p "npdata" -u "mcr.microsoft.com/azure-cognitive-services/vision/read:3.2" -r "2" -a "${ACTION}"



