# Setup

# Update

```bash
sudo apt update
sudo apt upgrade
```

Set up git

Generate ssh key using

```bash
ssh-keygen -t ed25519 -C "greenthegarden@gamil.com"
```


# cmdline

Ensure file `/boot/cmdline.txt` is in form of

```txt
console=serial0,115200 console=tty1 root=PARTUUID=30b195d8-02 rootfstype=ext4 fsck.repair=yes rootwait elevator=deadline  cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```



# Docker

Install Docker using

```bash
curl -fsSL https://get.docker.com -o docker-script.sh
sudo sh docker-script.sh
sudo usermod -aG docker pi
```

TODO: Look into rootless mode: https://docs.docker.com/go/rootless/

# Install Consul

See `/mnt/storage/consul.d/README.md`

# Install Nomad

See `/mnt/storage/nomad.d/README.md`

# Checks

## Open ports

```bash
sudo netstat -tulpn | grep LISTEN
sudo iptables -S
sudo nmap -sT -O localhost
sudo nmap -sU -O 192.168.2.254 ##[ list open UDP ports ]##
sudo nmap -sT -O 127.0.0.1 ##[ list open TCP ports ]##
sudo nmap -sTU -O 192.168.2.24
```

## Running services


# Nomad

## Check job

```bash
nomad job validate job.hcl
```

## Plan

```bash
nomad job plan job.hcl
```

## Run

```bash
nomad job run job.hcl
```

