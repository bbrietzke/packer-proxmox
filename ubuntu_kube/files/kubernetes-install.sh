#! /bin/bash

sudo tee /etc/modules-load.d/containerd.conf << EOF
overlay
br_netfilter
EOF

sudo tee /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

sudo modprobe overlay && sudo modprobe br_netfilter && sudo sysctl --system

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg  --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list 


while sudo fuser /var/lib/dpkg/lock > /dev/null 2>&1; do
    echo "Waiting for /var/lib/dpkg/lock to be released"
    sleep 10
done 

while sudo fuser /var/lib/apt/lists/lock > /dev/null 2>&1; do
    echo "Waiting for /var/lib/apt/lists/lock to be released"
    sleep 10
done

sudo apt update 
sudo apt install -y containerd.io kubelet kubeadm kubectl

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1 
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl enable containerd 
sudo systemctl restart containerd

