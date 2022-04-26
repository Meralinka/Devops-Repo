provider "aws" {
  region = "us-east-1"

}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

data "aws_vpc" "main_vpc" {
  default = true
}
data "aws_ami" "tf_ami" {
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
}

resource "aws_security_group" "ec2-instance-SG" {
  name        = "Ec2-SG"
  description = "ssh and http"
  vpc_id      = data.aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.tf_ami.id
  instance_type          = "t2.micro"
  key_name               = "firstkey"
  user_data              = file("./post_config.sh")
  vpc_security_group_ids = [aws_security_group.ec2-instance-SG.id]
  tags = {
    "Name" = "Web Server of Phonebook"
  }

}

output "public_ip" {
  value = aws_instance.webserver.associate_public_ip

}