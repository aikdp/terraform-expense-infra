#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "backend_sg_id" {
  name = "/${var.project_name}/${var.environment}/backend_sg_id"    #Craete VPN SG first then Store it and take it
}

#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/private_subnet_ids"
}


#Taking OpenVpn 
data "aws_ami" "devops" {
  most_recent      = true
  owners = ["973714476881"] #copy from AWS Account

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}