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