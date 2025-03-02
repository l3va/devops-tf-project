# devops-tf-project
# Deploy VPC, private/public subnets, security groups and EC2 instance with Ubuntu 22 
# TODO:
1) configure prometheus on public instance
2) configure configure grafana on private instance
3) configure public instance prometheus as data source for grafana on private instance
4) monitor and display cpu and other metrics on private instance

5) Expand bash script and add nginx
6) Configure Jenkins to work with terraform


# NOTE: 
in /etc/prometheus/prometheus.yml on monitoring ubuntu
replace 
      # - targets: ["<web_server_ip>:9100"]
<web_server_ip> with web server public ip