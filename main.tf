terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2-instance" {
  ami           = var.ami
  instance_type = var.instance_type

  # For attaching Security Group

  security_groups = [aws_security_group.DEMO_SG.name]

  # For attaching Key Pair

  key_name = var.kp_filename # Key Pair name

  # For setting the root volume size and type, by default root attach to an ec2 instance


  root_block_device {
    volume_size = var.root_vol_size  # Set the root volume size in GiB
    volume_type = var.root_vol_type
  }
  tags = {
    Name = var.instance_name
  }
}

output "aws_ec2_public_ips" {
	value = aws_instance.ec2-instance.public_ip
}

resource "aws_security_group" "DEMO_SG" {
  name        = var.s_g_name
  description = var.s_g_description

  # Security Group is created in a particular VPC

  vpc_id      = var.vpc_id

  # For inbound rules you need to specify ingress block

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Solr"
    from_port   = 8983
    to_port     = 8983
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # For outbound rules you need to specify egress block

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags are used to give the name

  tags = {
	Name = var.s_g_name
  }
}

resource "aws_key_pair" "DEMO_KP" {
  key_name   = var.kp_filename # Key Pair Name, we have to give this same key name in ec2 block
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "DEMO_Key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = var.kp_filename
}

output "ec2_details" {
	value = aws_instance.ec2-instance
}

resource "aws_ebs_volume" "vol" {
  availability_zone = aws_instance.ec2-instance.availability_zone
  size              = var.vol_size
  type              = var.volume_type  # Specify the volume type as gp2 for DEMO
  tags = {
    Name = var.ebs_vol_name
  }
}

resource "aws_volume_attachment" "vol_attachment" {
  volume_id      = aws_ebs_volume.vol.id
  instance_id    = aws_instance.ec2-instance.id
  device_name    = var.ebs_device_name
}

output "ebs_vol_details" {
        value = aws_ebs_volume.vol
}
output "pem_file_path" {
  value = local_file.DEMO_Key.filename
}
output "instance_name" {
  value = aws_instance.ec2-instance.tags["Name"]
}

