resource "aws_instance" "docker_ec2" {
  ami           = "ami-04b4f1a9cf54c11d0"  # Amazon Linux 2 AMI (Change if needed)
  instance_type = "t2.micro"  # Choose an instance type as per requirements
  key_name      = "NewKey_310324"  # Replace with your existing key pair
  security_groups = [aws_security_group.docker_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              # Pull and run JMeter container
              sudo docker pull justb4/jmeter
              sudo docker run -d --name jmeter-server -p 1099:1099 justb4/jmeter
              EOF
  tags = {
    Name = "Docker-EC2"
  }
}

resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "Allow SSH and Docker access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to your IP for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
