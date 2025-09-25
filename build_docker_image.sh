#!/bin/bash

# -------------------------------
# Install Docker on Amazon Linux
# -------------------------------
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Optional: switch to docker group immediately (so sudo is not required for docker commands in the same session)
newgrp docker << EOF

# -------------------------------
# Verify Docker installation
# -------------------------------
docker info

# -------------------------------
# Build the Docker image
# -------------------------------
# Make sure the Dockerfile is in the same directory as this script
docker build -t <your-docker-image-name> .

# -------------------------------
# Docker Hub Login
# -------------------------------
# Ensure ~/my_password.txt contains your Docker Hub password or access token
cat ~/my_password.txt | docker login -u <username> --password-stdin

# -------------------------------
# Tag the image for Docker Hub
# -------------------------------
docker tag onewaydock:latest your-docker-username/onewaydock:latest

# -------------------------------
# Push the image to Docker Hub
# -------------------------------
docker push your-docker-username/your-docker-image-name:latest

# -------------------------------
# Remove old containers (if any)
# -------------------------------
docker rm -f $(docker ps -aq) 2>/dev/null || true

# -------------------------------
# Run the container on port 80
# -------------------------------
docker run -dp 80:80 --restart unless-stopped your-docker-username/your-docker-image-name:latest

EOF

