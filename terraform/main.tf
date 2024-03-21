locals {
  key_path = "/Users/jiashuhuang/Documents/Dark-Horse/AWS/example-instance-key.pem"
}
provider "aws" {
  region = "us-east-1" // Change to your preferred AWS region
}

resource "aws_security_group" "allow_jenkins" {
  name        = "allow_jenkins"
  description = "Allow Jenkins to access the EC2 instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "jenkins-intro" {
  ami             = "ami-080e1f13689e07408" // Replace with the actual Ubuntu AMI ID
  instance_type   = "t2.micro"
  key_name        = "example-instance-key"
  security_groups = [aws_security_group.allow_jenkins.name]
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "Jenkins Intro"
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu" // Default user for Ubuntu AMIs
      private_key = file(local.key_path)
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" // Default user for Ubuntu AMIs
      private_key = file(local.key_path)
      host        = self.public_ip
    }
  }
}
