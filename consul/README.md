# Consul configuration

Sources:

https://medium.com/swlh/running-hashicorp-nomad-consul-pihole-and-gitea-on-raspberry-pi-3-b-f3f0d66c907
https://www.nomadproject.io/docs/integrations/consul-connect


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

TODO: Fix setting bind_addr
TODO: Fix setting encrypt

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

systemclt commands

Start service: `sudo systemctl start consul`
Enable service (run at startup): `sudo systemctl enable consul`
Restart service: `sudo systemctl restart consul`
Check status: `systemctl status consul`
Stop service: `sudo systemctl stop consul`
Disable service: `sudo systemctl disable consul`
Edit service definition: `sudo systemctl edit consul`

View logs: `journalctl -u consul -f`