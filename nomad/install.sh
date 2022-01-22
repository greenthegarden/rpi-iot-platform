#!/usr/bin/env bash


NOMAD_VERSION=1.2.4
NOMAD_BIN=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_arm.zip

# # install nomad
# wget ${NOMAD_BIN} -O nomad.zip
# unzip nomad.zip && sudo mv nomad /usr/local/bin
# rm nomad.zip

# nomad --version


# prepare configuration area

NOMAD_BASE=/mnt/storage/nomad

sudo mkdir -p ${NOMAD_BASE}
sudo mkdir ${NOMAD_BASE}/{conf,data,nomad.d}

# add configuration
sudo cp nomad.d/{client,server}.hcl ${NOMAD_BASE}/nomad.d

# copy jobs
sudo cp -R jobs ${NOMAD_BASE}

# create user and set permissions
sudo useradd nomad -s /bin/false -d ${NOMAD_BASE}/nomad.d -G pi,docker
sudo usermod -a -G nomad pi
sudo chown -R nomad:nomad ${NOMAD_BASE}
sudo chmod -R 775 ${NOMAD_BASE}

# add service definition
sudo cp nomad.service /etc/systemd/system/
sudo systemctl enable nomad
systemctl status nomad
