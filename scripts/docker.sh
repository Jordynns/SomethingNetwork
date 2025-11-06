#!/bin/bash

echo "Docker / Portainer Installing..."

echo "Updating and Upgrading System..."
sudo apt update && sudo apt upgrade -y

echo "Installing Certificates..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

echo "Setting up Docker Keyrings..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating System and Installing Docker..."
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

echo "Enabling and Starting Docker Service"
sudo systemctl enable docker
sudo systemctl start docker

echo "Creating Portainer Volume"
docker volume create portainer_data

echo "Creating Portainer Container, running on port 9443"
docker run -d -p 8000:8000 -p 9443:9443 \
    --name=portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
