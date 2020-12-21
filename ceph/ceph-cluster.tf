terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}


resource "aws_vpc" "ceph" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "Ceph VPC"
  }
}

resource "aws_subnet" "ceph" {
  vpc_id     =  aws_vpc.ceph.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Ceph Internal"
  }
}
resource "aws_subnet" "cephadm" {
  vpc_id     =  aws_vpc.ceph.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Ceph Adm"
  }
}



resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.cephadm.id
  tags = {
    Name = "Ceph NAT GW"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_route_table" "internet_rt" {
  vpc_id = aws_vpc.ceph.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Ceph Internet GW"
  }
}

resource "aws_route_table_association" "nat" {
  subnet_id      = aws_subnet.ceph.id
  route_table_id = aws_route_table.nat_rt.id
}

resource "aws_route_table_association" "internet_rt" {
  subnet_id      = aws_subnet.cephadm.id
  route_table_id = aws_route_table.internet_rt.id
}



resource "aws_route_table" "nat_rt" {
  vpc_id = aws_vpc.ceph.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "Ceph RT"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.ceph.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.ceph.cidr_block, "0.0.0.0/0" ]
  }

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { 
	description = "OSDs"
        from_port = 6800
        to_port = 7300
        protocol = "tcp"
        cidr_blocks = [ aws_vpc.ceph.cidr_block ]
  }

  ingress {
	description = "Monitors v1"
        from_port = 3300
	to_port = 3330
        protocol = "tcp" 
        cidr_blocks = [ aws_vpc.ceph.cidr_block ]
  }
  ingress {
	description = "Monitors v2"
        from_port = 6789 
	to_port = 6789
        protocol = "tcp" 
        cidr_blocks = [ aws_vpc.ceph.cidr_block ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ceph allow_ssh and ping"
  }
}

resource "aws_key_pair" "terraformcluster" {
  key_name   = "terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM/LV7yTkKjXJbKl/ity2ccbrI6NzCJMBC4yFRM5WKGlQeoJiKkGJxbzwhFULJc7QcjF1RQ4lcoReXPOc2H9q9kx5aqymzpLMMraF6yWjN2JPRkx8VJSnwiB3O23vhKg97RPBgSJ+HbRyA+ttWGas++A8JubgScq+Cx9PDGyaQ7ZhmRKNIvG+Nu2JdDJQAEfHo38jJiwBQ7KIGec47kenK691NOyeeKhQwA5yVt0EdX4X7JpgIDxltvU3mcKn+L3kdT0UCW39gP7PTj3brQbEhcm5BPdBm1jRiasNCeQPT/REgrFVODwsOpX5vsDl3SA9VCBxY4bzqvyLmJLLmf05FtSY0VaNsDRUR4KD0iuufGRXZHo+DQsV04pl6W1bCx7Ct7bKJhCsdiqmGBBVXv+2twXRF8GTgsCIe0glzCBWmhaSYRpRjX8gX7jG0dkmwYrtLwddsdLqKp7nkVCRO7LMrrrEoVsQvEZIhyd5+rW7admWZG26OBMavF2q4Tuc13mc= ubuntu@ip-172-31-36-152"
}



resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ceph.id

  tags = {
    Name = "Ceph Gateway"
  }
}


