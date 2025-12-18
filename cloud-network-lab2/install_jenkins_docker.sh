#!/bin/bash
set -e

# --------- System update ----------
yum update -y

# --------- Install Java (required for Jenkins) ----------
amazon-linux-extras install java-openjdk11 -y

# --------- Install Jenkins ----------
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y

systemctl enable jenkins
systemctl start jenkins

# --------- Install Docker ----------
yum install docker -y
systemctl enable docker
systemctl start docker

# Allow Jenkins to run Docker commands
usermod -aG docker jenkins

# --------- Install AWS CLI v2 ----------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# --------- Restart Jenkins to apply group changes ----------
systemctl restart jenkins

echo "Jenkins, Docker and AWS CLI installed successfully"
