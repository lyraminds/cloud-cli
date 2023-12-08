#!/bin/bash
source conf/default.env
source cloud-cli/init.sh

./aws/cli.sh
./aws/codedeploy.sh



