locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "cloud-network-lab2"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, {
    Name = "vnet-nebo"
  })
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.128.0/17"

  tags = merge(local.common_tags, {
    Name = "snet-private"
  })
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/17"

  tags = merge(local.common_tags, {
    Name = "snet-public"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "snet-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "snet-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

data "aws_ami" "ubuntu22" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "ec2_user_data" {
  template = "${file("${path.module}/notebook_bootstrap_ubuntu22.txt")}"
}

resource "aws_instance" "public" {
  ami = data.aws_ami.ubuntu22.id
  instance_type = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_web_traffic.id]
  key_name = "default-key-pair"
  user_data = "${data.template_file.ec2_user_data.template}"
  root_block_device {
    delete_on_termination = true
    volume_size = var.ec2_volume_config.size
    volume_type = var.ec2_volume_config.type
  }

  tags = merge(local.common_tags, {
    Name = "snet-public-ubuntu"
  })
}

resource "aws_security_group" "public_web_traffic" {
  description = "Security group rule allowing traffic on ports 443 and 80"
  name = "public_web_traffic"
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "snet-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = "80"
  to_port = "80"
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = "443"
  to_port = "443"
  ip_protocol = "tcp"
}

# resource "aws_vpc_security_group_ingress_rule" "ssh" {
#   security_group_id = aws_security_group.public_web_traffic.id
#   cidr_ipv4 = "${var.my_ip}/32"
#   from_port = "22"
#   to_port = "22"
#   ip_protocol = "tcp"
# }

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = "0"
  to_port = "0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "jupyter" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.jupyter_port
  to_port = var.jupyter_port
  ip_protocol = "tcp"
}
