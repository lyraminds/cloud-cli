
_CC_REGION=${1:-${CC_REGION}}

source base.sh

nlog "#Aws codedeploy"
run-install "ruby-full wget"
#TODO can home folders differ
run-cmd "cd ~/ && \
wget https://aws-codedeploy-${_CC_REGION}.s3.${_CC_REGION}.amazonaws.com/latest/install && \
chmod +x ./install && \
sudo ./install auto && \
sudo service codedeploy-agent status "
