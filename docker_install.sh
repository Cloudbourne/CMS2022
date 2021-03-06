#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce=18.06.3~ce~3-0~ubuntu
if [ $? -eq 0 ]; then
        echo "Docker installed successfully"
        sudo docker version
        sudo usermod -aG docker $(whoami)
else
        echo "couldn't complete installtion"
fi
