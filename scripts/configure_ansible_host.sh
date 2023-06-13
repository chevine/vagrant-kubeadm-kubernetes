#!/bin/bash
#
# Common setup for all non-Kubernetes hosts

set -euxo pipefail

# Variable Declaration

# DNS Setting
if [ ! -d /etc/systemd/resolved.conf.d ]; then
	sudo mkdir /etc/systemd/resolved.conf.d/
fi
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=${DNS_SERVERS}
EOF

sudo systemctl restart systemd-resolved

# disable swap
sudo swapoff -a

# keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y

sudo sysctl --system

# Install Ansible
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible ansible-lint -y

#
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
ssh-copy-id -i ~/.ssh/id_rsa.pub master-node
ssh-copy-id -i ~/.ssh/id_rsa.pub worker-node01