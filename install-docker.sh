#!/bin/bash
source conf/default.env
source accounts/private-azure.env
source cloud-cli/init.sh

export CC_MODE=live

./docker/cli.sh


run-git "${CC_GIT_URL}/eclarity" "weasis-pacs-connector"






