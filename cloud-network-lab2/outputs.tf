output "ubuntu_public_ip" {
  value = aws_instance.public.public_ip
}

output "ubuntu_public_name" {
  value = aws_instance.public.tags_all.Name
}

output "ubuntu_public_os" {
  value = data.aws_ami.ubuntu22.name
}

output "jupyter_URL" {
  value = "http://${aws_instance.public.public_ip}:${var.jupyter_port}"
}

output "prometheus_URL" {
  value = "http://${aws_instance.monitoring.public_ip}:${var.prometheus_port}"
}

output "grafana_URL" {
  value = "http://${aws_instance.monitoring.public_ip}:${var.grafana_port}"
}


# new ones
# ---------------- Jenkins ----------------

output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins_server.public_dns}:8080"
}

# ---------------- Nginx ECS ----------------

output "nginx_app_url" {
  value = "http://${aws_lb.nginx_alb.dns_name}"
}

# ---------------- ECS Info ----------------

output "ecs_cluster_name" {
  value = aws_ecs_cluster.devops_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.nginx_service.name
}

# ---------------- ECR ----------------

output "ecr_repository_url" {
  value = aws_ecr_repository.nginx_app_repo.repository_url
}
