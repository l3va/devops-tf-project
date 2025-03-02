variable "ec2_instance_type" {
  type        = string
  description = "The type of managed EC2 instances"

  #   validation {
  #     condition     = contains(["t2.micro", "t3.micro"], var.ec2_instance_type)
  #     error_message = "Only suppots t2.micro and t3.micro"
  #   }

  default = "t2.micro"
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

# variable "my_ip" {
#   description = "Public IP of local machine to apply ssh access"
#   type        = string
# }

variable "jupyter_port" {
  type        = string
  description = "HTTP port on which Jupyter Lab service will be running"

  default = "8879"
}

variable "prometheus_port" {
  type        = string
  description = "HTTP port on which Jupyter Lab service will be running"

  default = "9090"
}

variable "grafana_port" {
  type        = string
  description = "HTTP port on which Jupyter Lab service will be running"

  default = "3000"
}

variable "node_exporter_port" {
  type        = string
  description = "HTTP port on which Jupyter Lab service will be running"

  default = "9100"
}
