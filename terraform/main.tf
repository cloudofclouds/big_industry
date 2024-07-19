provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins-master-sg"
  description = "Security group for Jenkins master"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Jenkins access"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_security_group" "jenkins_slave_sg" {
  name        = "jenkins-slave-sg"
  description = "Security group for Jenkins slaves"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip, "54.202.83.34/32"]
  }

  ingress {
    description = "Jenkins master dynamic ports"
    from_port   = 49152
    to_port     = 65535
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

resource "aws_eip" "jenkins_master_eip" {
  instance = aws_instance.jenkins_master.id
  vpc      = true

  tags = {
    Name = "Elastic IP for Jenkins Master"
  }
}

resource "aws_instance" "jenkins_master" {
  ami                    = var.ami_id
  instance_type          = var.jenkins_master_instance_type
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.jenkins_master_sg.name]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "install_packages.sh"
    destination = "/tmp/install_packages.sh"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_packages.sh",
      "/tmp/install_packages.sh",
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Jenkins-Master"
  }
}

resource "aws_instance" "jenkins_slave" {
  count                  = var.jenkins_slave_count
  ami                    = var.ami_id
  instance_type          = var.jenkins_slave_instance_type
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.jenkins_slave_sg.name]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "install_packages.sh"
    destination = "/tmp/install_packages.sh"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_packages.sh",
      "/tmp/install_packages.sh",
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Jenkins-Slave-${count.index + 1}"
  }
}

resource "aws_eip" "jenkins_slave_eip" {
  count    = var.jenkins_slave_count
  instance = aws_instance.jenkins_slave[count.index].id
  vpc      = true

  tags = {
    Name = "Elastic IP for Jenkins Slave ${count.index + 1}"
  }
}

output "jenkins_master_instance_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_master_eip" {
  value = aws_eip.jenkins_master_eip.public_ip
}

output "jenkins_slave_instance_ips" {
  value = [for instance in aws_instance.jenkins_slave : instance.public_ip]
}

output "jenkins_slave_eips" {
  value = [for eip in aws_eip.jenkins_slave_eip : eip.public_ip]
}
