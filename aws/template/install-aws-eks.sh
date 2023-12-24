#!/bin/bash
source zlink.sh

export CC_MODE=live

./aws/cli.sh
./aws/codedeploy.sh



