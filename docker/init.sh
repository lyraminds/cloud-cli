
source bin/base.sh

if [ $(installed "docker") == "false" ]; then

nlog "#Docker"

    if [ "$CC_OS" == "ubuntu" ]; then    

        run-install "ca-certificates curl gnupg"

        run-cmd "sudo install -m 0755 -d /etc/apt/keyrings \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
        sudo chmod a+r /etc/apt/keyrings/docker.gpg"

        run-cmd "echo \
        \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"


    elif [ "$CC_OS" == "centos" ] || [ "$CC_OS" == "amazon" ]; then    

        run-install "yum-utils"
        run-cmd "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"

    fi

    run-install "docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
fi

docker -v
# docker compose version




