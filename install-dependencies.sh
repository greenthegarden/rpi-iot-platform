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

# install and configure unbound as recursive DNS server
sudo apt install unbound apparmor apparmor-profiles-extra apparmor-utils
sudo cp unbound/consul.conf /etc/unbound/unbound.conf.d
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl restart unbound
