# Configure AWS provider
provider "aws" {
  region  = "ap-south-1"
  profile = "docker-aws"
}

# Default VPC
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

# Get availability zones
data "aws_availability_zones" "available_zones" {}

# Default subnet
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# Security group for EC2
resource "aws_security_group" "ec2_security_group" {
  name        = "docker-server-sg1"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker server sg"
  }
}

# Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# EC2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "your-ec2-key"

  tags = {
    Name = "docker server"
  }
}

# Provisioning
resource "null_resource" "docker_setup" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Users/your-username/Downloads/mumbai-1.pem") # update!
    host        = aws_instance.ec2_instance.public_ip
  }

  provisioner "file" {
    source      = "/Users/your-username/Downloads/my_password.txt" # update!
    destination = "/home/ec2-user/my_password.txt"
  }

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/home/ec2-user/Dockerfile"
  }

  provisioner "file" {
    source      = "build_docker_image.sh"
    destination = "/home/ec2-user/build_docker_image.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/build_docker_image.sh",
      "sh /home/ec2-user/build_docker_image.sh",
    ]
  }

  depends_on = [aws_instance.ec2_instance]
}

# Output container URL
output "container_url" {
  value = "http://${aws_instance.ec2_instance.public_dns}"
}



