#!/bin/bash

sudo exec 1>/home/app/install.log

echo -e "Start Install DOCKER\n"

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-compose htop
sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs

echo -e "Finish Install DOCKER\n"
