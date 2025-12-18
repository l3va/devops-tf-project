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
  owners      = ["amazon"]

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
  template = file("${path.module}/notebook_bootstrap_ubuntu22.txt")
}

data "template_file" "ec2_monitoring_user_data" {
  template = templatefile("${path.module}/monitoring_bootstrap.txt", { web_server_ip = aws_instance.public.public_ip })
}

data "template_file" "ec2_node_exporter_user_data" {
  template = file("${path.module}/node_exporter_bootstrap.txt")
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.ubuntu22.id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_web_traffic.id]
  key_name                    = "default-key-pair"
  # user_data                   = data.template_file.ec2_user_data.template
  user_data = data.template_file.ec2_node_exporter_user_data.template

  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2_volume_config.size
    volume_type           = var.ec2_volume_config.type
  }

  tags = merge(local.common_tags, {
    Name = "snet-public-ubuntu"
  })
}

resource "aws_instance" "private" {
  ami           = data.aws_ami.ubuntu22.id
  instance_type = var.ec2_instance_type
  # associate_public_ip_address = true
  subnet_id = aws_subnet.private.id
  # vpc_security_group_ids = [aws_security_group.public_web_traffic.id]
  key_name = "default-key-pair"
  # user_data = "${data.template_file.ec2_user_data.template}"
  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2_volume_config.size
    volume_type           = var.ec2_volume_config.type
  }

  tags = merge(local.common_tags, {
    Name = "snet-private-ubuntu"
  })
}

resource "aws_instance" "monitoring" {
  ami                         = data.aws_ami.ubuntu22.id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_web_traffic.id]
  key_name                    = "default-key-pair"
  # user_data = "${data.template_file.ec2_user_data.template}"
  user_data = data.template_file.ec2_monitoring_user_data.template
  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2_volume_config.size
    volume_type           = var.ec2_volume_config.type
  }

  depends_on = [aws_instance.public]

  tags = merge(local.common_tags, {
    Name = "snet-monitoring"
  })
}

resource "aws_security_group" "public_web_traffic" {
  description = "Security group rule allowing traffic on ports 443 and 80"
  name        = "public_web_traffic"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "snet-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = "80"
  to_port           = "80"
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = "443"
  to_port           = "443"
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  # from_port         = "0"
  # to_port           = "0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "jupyter" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.jupyter_port
  to_port           = var.jupyter_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "prometheus" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.prometheus_port
  to_port           = var.prometheus_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "grafana" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.grafana_port
  to_port           = var.grafana_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_exporter" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.node_exporter_port
  to_port           = var.node_exporter_port
  ip_protocol       = "tcp"
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.public_web_traffic.id
  cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
  from_port         = "22"
  to_port           = "22"
  ip_protocol       = "tcp"
}



# jenkins
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.amzn2.id       # Amazon Linux 2 latest AMI  
  instance_type = "t3.small"  
  subnet_id     = var.public_subnet_id        # use existing subnet from VPC  
  security_groups = [aws_security_group.jenkins_sg.id]  
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.id  
  user_data = file("${path.module}/install_jenkins_docker.sh") 
  tags = { Name = "JenkinsServer" }
}

# docker
resource "aws_ecr_repository" "nginx_app_repo" {
  name                 = "nginx-app-repo"
  image_scanning_configuration = { scan_on_push = true }
  encryption_configuration    = { encryption_type = "AES256" }
  tags = { Name = "NginxAppRepo" }
}

resource "aws_ecs_cluster" "devops_cluster" {
  name = "devops-ecs-cluster"
  tags = { Name = "DevOpsECSCluster" }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}
resource "aws_iam_role_policy_attachment" "ecs_task_ecr" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"                      # 0.25 vCPU
  memory                   = "512"                      # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  container_definitions    = jsonencode([
    {
      name      = "nginx-app",
      image     = "${aws_ecr_repository.nginx_app_repo.repository_url}:${var.app_image_tag}",
      portMappings = [
        { containerPort = 80, hostPort = 80, protocol = "tcp" }
      ],
      essential = true
    }
  ])
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-app-service"
  cluster         = aws_ecs_cluster.devops_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn  # initial task def
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = var.private_subnets  # run tasks in private subnets
    security_groups  = [aws_security_group.nginx_task_sg.id] 
    assign_public_ip = false  # use false if behind ALB in private subnets
  }
  load_balancer { 
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    container_name   = "nginx-app"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.http]  # ensure LB listener created first
}
