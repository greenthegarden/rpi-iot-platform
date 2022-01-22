#!/usr/bin/env bash


CONSUL_VERSION=1.11.2
CONSUL_BIN=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_arm.zip

# # install consul
# wget ${CONSUL_BIN} -O consul.zip
# unzip consul.zip && sudo mv consul /usr/local/bin
# rm consul.zip

# consul --version

# consul keygen

# prepare configuration area

CONSUL_BASE=/mnt/storage/consul

sudo mkdir -p ${CONSUL_BASE}
sudo mkdir ${CONSUL_BASE}/{conf,consul.d,data}

# add configuration
sudo cp consul.d/server.json ${CONSUL_BASE}/consul.d

# create user and set permissions
sudo useradd consul -s /bin/false -d ${CONSUL_BASE}/consul.d -G pi,docker
sudo usermod -a -G consul pi
sudo chown -R consul:consul ${CONSUL_BASE}
sudo chmod -R 775 ${CONSUL_BASE}

# add service definition
sudo cp consul.service /etc/systemd/system/
sudo systemctl enable consul
systemctl status consul
