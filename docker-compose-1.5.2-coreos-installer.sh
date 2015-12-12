#!/bin/bash

# Releases: https://github.com/docker/compose/releases
# Instructions: https://docs.docker.com/compose/install/
sudo su
mkdir -p /opt/bin
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /opt/bin/docker-compose
chmod +x /opt/bin/docker-compose
exit
