
source bin/base.sh

initfirst(){
if [ $(installed "pwgen") == "false" ]; then
run-install "pwgen"
fi
}

initfirst

buildconf
buildlog

initlog

buildbase
buildbaseapp
