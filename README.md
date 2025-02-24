# devops-tf-project
export MY_IP=$(curl -s https://api.ipify.org) \n
terraform apply -var "my_ip=${MY_IP}"