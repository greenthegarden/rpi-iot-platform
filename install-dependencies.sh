#!/usr/bin/env bash

# upgrade system
sudo apt update
sudo apt upgrade

# install utilities
sudo apt install git neovim htop

# install docker
curl -fsSL https://get.docker.com -o docker-script.sh
sudo sh docker-script.sh
sudo usermod -aG docker pi

