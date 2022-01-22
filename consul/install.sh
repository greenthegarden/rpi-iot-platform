#!/usr/bin/env bash


CONSUL_VERSION=1.11.2
CONSUL_BIN=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_arm.zip
CONSUL_SHA=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS
CONSUL_SIG=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig

install () {
  # install consul
  printf "Installing Hashicorp Consul version %s\n" ${CONSUL_VERSION}
  cd /tmp && \
  wget ${CONSUL_BIN} && \
  wget ${CONSUL_SHA} && \
  wget ${CONSUL_SIG} && \
  grep consul_${CONSUL_VERSION}_linux_arm.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
  sudo unzip -d /usr/local/bin consul_${CONSUL_VERSION}_linux_arm.zip

  consul --version

  consul keygen
}

configure () {
  CONSUL_BASE=/mnt/storage/consul
  printf "Configuring Hashicorp Consul at %s\n" ${CONSUL_BASE}
  # prepare configuration area
  sudo mkdir -p ${CONSUL_BASE}
  sudo mkdir ${CONSUL_BASE}/{conf.d,data}

  # add configuration
  sudo cp conf.d/server.json ${CONSUL_BASE}/conf.d

  # create user and set permissions
  sudo useradd consul -s /bin/false -d ${CONSUL_BASE}/conf.d -G pi,docker
  sudo usermod -a -G consul pi
  sudo chown -R consul:consul ${CONSUL_BASE}
  sudo chmod -R 775 ${CONSUL_BASE}
}

run () {
  printf "Running Hashicorp Consul as a service\n"
  # add service definition
  sudo cp consul.service /etc/systemd/system/
  sudo systemctl enable consul
  sudo systemctl start consul
  systemctl status consul
}

# run script
install
configure
run
