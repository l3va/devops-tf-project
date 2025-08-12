variable "ec2_instance_type" {
  type        = string
  description = "The type of managed EC2 instances"
  default     = "t2.micro"
}

variable "ec2_volume_config" {
  type = object({
    size = number
    type = string
  })
  description = "The size in GB and type of the volume of the root block volume attached to managed EC2 instances"
  default = {
    size = 10
    type = "gp3"
  }
}

variable "jupyter_port" {
  type        = string
  description = "HTTP port on which Jupyter Lab service will be running"

  default = "8879"
}

variable "prometheus_port" {
  type        = string
  description = "HTTP port on which Prometheus service will be running"

  default = "9090"
}

variable "grafana_port" {
  type        = string
  description = "HTTP port on which Grafana service will be running"

  default = "3000"
}

variable "node_exporter_port" {
  type        = string
  description = "HTTP port on which Node Exporter service will be running"

  default = "9100"
}
