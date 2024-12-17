#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "vpn_sg_id" {
  name = "/${var.project_name}/${var.environment}/vpn_sg_id"    #Craete VPN SG first then Store it and take it
}

#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}


#Taking OpenVpn 
data "aws_ami" "openvpn" {
  most_recent      = true
  owners = ["679593333241"] #copy from AWS Account

  filter {
    name   = "name"
    values = ["OpenVPN Access Server Community Image-fe8020db-*"]
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