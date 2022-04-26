provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

resource "aws_instance" "hw-ec2" {
  ami             = data.aws_ami.tf_ami.id
  instance_type   = "t2.micro"
  key_name        = "firstkey"
  security_groups = ["odev-sec-grp"]
  count           = 2
  tags = {
    Name = "Terraform ${element(var.hw-ec2-tags, count.index)} Instance"
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("firstkey.pem")

  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum -y install httpd",
      "sudo chmod -R 777 /var/www/html",
      "sudo echo 'Hello World' > /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]

  }

    provisioner "local-exec" {
    command = "echo http://${self.public_ip} > public_ip.txt"
  }

  provisioner "local-exec" {
    command = "echo http://${self.private_ip} > private_ip.txt"
  }




}

resource "aws_security_group" "odev-sec-grp" {
  name = "odev-sec-grp"
  tags = {
    Name = "odev-sec-grp"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }



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



