# Linux Pre-Installation Procedure - With a GPU

## CUDA Installation Guide

Configuring a system with a GPU is a big task and has many nauances to consider. The link below is the guide if you get stuck. I've included command line instructions in two parts below.

https://docs.nvidia.com/cuda/cuda-installation-guide-linux

## Part 1
```
# Define the CUDA version to install
CUDA_VERSION=12.5.0
CUDA_PIN_VERSION=555.42.02-1
UBUNTU_VERSION=ubuntu2204
TOOLKIT_VERSION=12-5
ARCHITECTURE=amd64
USER=$(whoami)
CUDA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos"
CUDA_LOCAL_INSTALLER_URL="https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers"

echo "$USER ALL=(ALL) NOPASSWD: /bin/su -" | sudo EDITOR='tee -a' visudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
wget ${CUDA_REPO_URL}/${UBUNTU_VERSION}/x86_64/cuda-${UBUNTU_VERSION}.pin
sudo mv cuda-${UBUNTU_VERSION}.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget ${CUDA_LOCAL_INSTALLER_URL}/cuda-repo-${UBUNTU_VERSION}-${TOOLKIT_VERSION}-local_${CUDA_VERSION}-${CUDA_PIN_VERSION}_${ARCHITECTURE}.deb

sudo DEBIAN_FRONTEND=noninteractive dpkg -i cuda-repo-${UBUNTU_VERSION}-${TOOLKIT_VERSION}-local_${CUDA_VERSION}-${CUDA_PIN_VERSION}_${ARCHITECTURE}.deb
sudo cp /var/cuda-repo-${UBUNTU_VERSION}-${TOOLKIT_VERSION}-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install cuda-toolkit-${TOOLKIT_VERSION} cuda-drivers

sudo reboot

```

## Part 2
```
#!/bin/bash

# Enter any IPs or CIDR blocks you want to allow through your computers firewall
declare -a IPS=("192.168.1.0/24" "127.0.0.1")
declare -a PORTS=("443" "80" "22")

# Install essential packages and Docker CE
echo "Installing essential packages and Docker CE..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install apt-transport-https curl gnupg-agent ca-certificates software-properties-common jq -y

# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists
sudo DEBIAN_FRONTEND=noninteractive apt-get update

# Install Docker
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker-compose docker-ce docker-ce-cli containerd.io net-tools -y

# Create daemon.json for NVIDIA runtime
echo "Creating /etc/docker/daemon.json for NVIDIA runtime..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
EOF

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Install NVIDIA container toolkit
echo "Installing NVIDIA container toolkit..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/nvidia-docker.gpg
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
#sudo nvidia-container-runtime --version

# Enable and configure UFW for each IP and port
echo "Enabling and configuring UFW..."
sudo ufw --force enable > /dev/null 2>&1
for IP in "${IPS[@]}"; do
  for PORT in "${PORTS[@]}"; do
    sudo ufw allow from $IP to any port $PORT > /dev/null 2>&1
  done
done
sudo ufw reload > /dev/null 2>&1

# Add CUDA paths to environment variables
echo "Adding CUDA paths to environment variables..."
echo "export PATH=/usr/local/cuda-12.5/bin${PATH:+:${PATH}}" | sudo tee -a ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" | sudo tee -a ~/.bashrc
source ~/.bashrc
```

## Troubleshooting

### Test with CUDA container
```
echo "Testing CUDA container..."
sudo docker run --rm --gpus all nvidia/cuda:12.5.0-base-ubuntu22.04 nvidia-smi
```
