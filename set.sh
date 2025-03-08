#!/bin/bash

# Update package index
sudo apt-get update -y

# Install required packages
sudo apt-get install -y unzip zip git curl apt-transport-https ca-certificates software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker's stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package index again after adding the new repo
sudo apt-get update -y

# Install Docker CE (Community Edition)
sudo apt-get install -y docker-ce

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add the default user to the docker group (use `ec2-user` for Amazon Linux)
sudo usermod -aG docker ubuntu
newgrp docker  # Apply group change immediately

# Clone GitHub repository
git clone https://github.com/sivahari01/JmeterRunGit.git /root/JmeterRunGit

# Ensure the test file is copied correctly
cp /root/JmeterRunGit/mytest.jmx /root/

# Pull and run JMeter container
sudo docker pull justb4/jmeter
sudo docker run --rm -v /root/:/tests -v /root/:/results justb4/jmeter \
  -n -t /tests/mytest.jmx -l /results/results.jtl -e -o /results/html_report


# Zip the HTML report before uploading
sudo zip -r /root/html_report.zip /root/html_report


# Create AWS credentials file
  sudo mkdir -p ~/.aws
  sudo touch  ~/.aws/credentials
  sleep 10s
  echo "
  [default]
  aws_access_key_id=${var.AWS_ACCESS_KEY_ID}
  aws_secret_access_key=${var.AWS_SECRET_ACCESS_KEY} " > ~/.aws/credentials

sleep 5s
# Set correct permissions
 chmod 600 ~/.aws/credentials
 

# Install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install


# Verify AWS CLI installation
aws --version

# Upload report to S3
sudo aws s3 cp /root/html_report.zip s3://mykopsbkter/


echo "✅ Script execution completed successfully!"
