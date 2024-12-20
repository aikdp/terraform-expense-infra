#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "frontend_sg_id" {
  name = "/${var.project_name}/${var.environment}/frontend_sg_id"    #Craete VPN SG first then Store it and take it
}

#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

#Use SSM parameter store to store in aws and get the info using data source
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
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


#Use SSM parameter store to store in aws and get the info using data source
data "aws_ssm_parameter" "web_alb_listener_arn" {
  name = "/${var.project_name}/${var.environment}/web_alb_listener_arn"
}