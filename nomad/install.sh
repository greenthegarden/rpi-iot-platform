#!/usr/bin/env bash


NOMAD_VERSION=1.2.4
NOMAD_BIN=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_arm.zip
NOMAD_SHA=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS
NOMAD_SIG=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig

install () {
  # install nomad
  printf "Installing Hashicorp Nomad version %s\n" ${NOMAD_VERSION}
  cd /tmp && \
  wget ${NOMAD_BIN} && \
  wget ${NOMAD_SHA} && \
  wget ${NOMAD_SIG} && \
  grep nomad_${NOMAD_VERSION}_linux_arm.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c && \
  sudo unzip -d /usr/local/bin nomad_${NOMAD_VERSION}_linux_arm.zip

  nomad --version
}

configure () {
  NOMAD_BASE=/mnt/storage/nomad
  printf "Configuring Hashicorp Nomad at %s\n" ${NOMAD_BASE}
  # prepare configuration area
  sudo mkdir -p ${NOMAD_BASE}
  sudo mkdir ${NOMAD_BASE}/{conf.d,data}

  # add configuration
  sudo cp conf.d/{base,client,server}.hcl ${NOMAD_BASE}/conf.d

  # create user and set permissions
  sudo useradd nomad -s /bin/false -d ${NOMAD_BASE}/conf.d -G pi,docker
  sudo usermod -a -G nomad pi
  sudo chown -R nomad:nomad ${NOMAD_BASE}
  sudo chmod -R 775 ${NOMAD_BASE}
}

run () {
  printf "Running Hashicorp Nomad as a service\n"
  # add service definition
  sudo cp nomad.service /etc/systemd/system/
  sudo systemctl enable nomad
  sudo systemctl start nomad
  systemctl status nomad
}


# run script
install
configure
run
