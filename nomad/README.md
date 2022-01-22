Based on https://medium.com/swlh/running-hashicorp-nomad-consul-pihole-and-gitea-on-raspberry-pi-3-b-f3f0d66c907

Using Ansible roles
* https://github.com/ansible-community/ansible-consul
* https://github.com/ansible-community/ansible-nomad

On Raspbian I had to add the following in /boot/cmdline.txt

```
cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```

You must add this to the end of the existing line; if you add it at the bottom of file in a new line it doesn't work.

Start agemt


References:

https://medium.com/hashicorp-engineering/hashicorp-nomad-from-zero-to-wow-1615345aa539

Follow instructions from https://medium.com/swlh/running-hashicorp-nomad-consul-pihole-and-gitea-on-raspberry-pi-3-b-f3f0d66c907

Create user

```
sudo mkdir /mnt/storage
sudo mkdir /mnt/storage/nomad/conf
sudo mkdir /mnt/storage/nomad/nomad.d
sudo mkdir /mnt/storage/nomad/data
sudo useradd nomad -s /bin/false -d /mnt/storage/nomad/nomad.d -G pi
sudo usermod -a -G nomad pi
sudo chown -R nomad:nomad /mnt/storage/nomad
sudo chmod -R 775 /mnt/storage/nomad
```

```
sudo mkdir /mnt/storage/consul
sudo mkdir /mnt/storage/consul/conf
sudo mkdir /mnt/storage/consul/consul.d
sudo mkdir /mnt/storage/consul/data
sudo useradd consul -s /bin/false -d /mnt/storage/consul/consul.d -G pi
sudo usermod -a -G consul pi
sudo chown -R consul:consul /mnt/storage/consul
sudo chmod -R 775 /mnt/storage/consul

consul keygen
```

consul/server.json

```json
{
  "server": true,
  "datacenter": "dc1",
  "data_dir": "/mnt/storage/consul/data",
  "ui_config": {
    "enabled": true
  },
  "bind_addr": "192.168.1.191",
  "client_addr": "0.0.0.0",
  "bootstrap_expect": 1,
  "ports": {
    "grpc": 8502
  },
  "connect": {
    "enabled": true
  },
  "addresses": {
    "grpc": "127.0.0.1"
  },
  "encrypt": "IBxHqo47vUrvwIWcyVx3xmHQ4j/XM1PJ0qYFOFC5uYI="
}
```

nomad/server.hcl

```hcl
server {
  enabled = true
  bootstrap_expect = 1
}
data_dir  = "/mnt/storage/nomad/conf"
datacenter = "dc1"
bind_addr = "0.0.0.0"
ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}
consul {
  address = "127.0.0.1:8500"
}
acl {
  enabled    = false
  token_ttl  = "30s"
  policy_ttl = "60s"
}
```

nomad/client.hcl

```hcl
client {
  enabled = true
  network_interface = "eth0"
  server_join {
    retry_join = [
      "127.0.0.1"
    ]
    retry_max = 3
    retry_interval = "15s"
  }
  // host_volume "gitea-data" {
  //   path      = "/mnt/storage/nomad/data/gitea/data"
  //   read_only = false
  // }
  // host_volume "gitea-db" {
  //   path      = "/mnt/storage/nomad/data/gitea/db"
  //   read_only = false
  // }
}
```
/etc/systemd/system/nomad.service

```bash
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target
# When using Nomad with Consul it is not necessary to start Consul first. These
# lines start Consul before Nomad as an optimization to avoid Nomad logging
# that Consul is unavailable at startup.
Wants=consul.service
After=consul.service
[Service]
Type=simple
User=nomad
Group=nomad
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /mnt/storage/nomad/nomad.d
ExecStop=/bin/kill $MAINPID
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
TasksMax=infinity
OOMScoreAdjust=-1000
[Install]
WantedBy=multi-user.target
```

/etc/systemd/system/consul.service

```bash
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/mnt/storage/consul/consul.d/server.json

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/mnt/storage/consul/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

Follow instructions at https://www.nomadproject.io/docs/integrations/consul-connect to support consul connect

Install CNI Plugins using

```bash
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.1/cni-plugins-linux-arm-v1.0.1.tgz"
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
```

```bash
sudo nvim /etc/sysctl.d/97-bridge.conf
```

and add

```conf
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

To stop a job use

```bash
nomad job stop -purge <job>
```
