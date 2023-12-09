
source base.sh

if [ "${CC_ASK_LOGIN}" == 'true' ]; then
  read -sp "Azure password: " AZ_PASS && echo && az login -u ${CC_ACCOUNT_LOGIN_ID} -p $AZ_PASS
  az account list --output table
fi


# ./az/use-subscription.sh