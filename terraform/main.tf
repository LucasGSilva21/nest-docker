terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create a Private ECR registry
resource "aws_ecr_repository" "docker_repository" {
  name = "docker-repository"
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_vpc" "default" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "172.16.10.0/24"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "test-Key" # Create a "wellness-Key" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "tf-key" {
  content  = tls_private_key.pk.private_key_pem
  filename = "test-key-pair"
}

# Create EC2 instance where docker container will run
resource "aws_instance" "my_instance" {
  ami                         = "ami-0d7a109bf30624c99"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.kp.key_name
  associate_public_ip_address = true

  tags = {
    Name = "MyEC2Instance"
  }

  user_data = <<EOF
#!/bin/bash

sudo yum install docker -y
sudo systemctl enable docker --now

EOF
}