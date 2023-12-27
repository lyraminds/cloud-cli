
source bin/base.sh

if [ $(installed "oci") == "false" ]; then

nlog "#Oracle cloud infrastructure CLI"
run-cmd "bash -c \"$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)\""

run-cmd "oci setup config"

else
 info "OCI CLI found"
 oci --version
fi

bash -c "$(curl -L https://raw.githubusercontent.com/lyraminds/cloud-cli/main/bin/init.sh)"
