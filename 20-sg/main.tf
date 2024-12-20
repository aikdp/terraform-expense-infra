#Create MySQL Security Group
module "mysql_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "mysql"
    sg_tags = var.mysql_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}

#Create BACKEND Security Group
module "backend_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "backend"
    sg_tags = var.backend_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}

#Create FRONTEND Security Group
module "frontend_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "frontend"
    sg_tags = var.frontend_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}

#Create FRONTEND Security Group
module "bastion_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "bastion"
    sg_tags = var.bastion_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}

#Create ANSIBLE Security Group
module "ansible_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "ansible"
    sg_tags = var.ansible_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}


#Create Security group rules for allow traffic from backend to MySQL
resource "aws_security_group_rule" "mysql_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend_sg.id   #Source is backend and MySQL is allowing from backend
  security_group_id = module.mysql_sg.id    #adding SG rule in mysql
}

# #Create Security group rules for allow traffic from frontend to backend
# resource "aws_security_group_rule" "backend_frontend" {
#   type              = "ingress"
#   from_port         = 8080
#   to_port           = 8080
#   protocol          = "tcp"
#   source_security_group_id = module.frontend_sg.id   #Source is backend and backend is allowing from frontend
#   security_group_id = module.backend_sg.id    #adding SG rule in backend
# }

# #Create Security group rules for allow traffic from  public to frontend
# resource "aws_security_group_rule" "frontend_public" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]   #Source is public and frontend is allowing from public
#   security_group_id = module.frontend_sg.id    #adding SG rule in frontend
# }

#Create Security group rules for allow traffic from bastion to mysql
resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306  #we are moving to RDS so chnage port 22 to 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id  
  security_group_id = module.mysql_sg.id 
}

#Create Security group rules for allow traffic from bastion to backend
resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id  
  security_group_id = module.backend_sg.id 
}

#Create Security group rules for allow traffic from bastion to frontend
resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id  
  security_group_id = module.frontend_sg.id 
}

#Create Security group rules for allow traffic from  public to bastion
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
  security_group_id = module.bastion_sg.id 
}

# #Create Security group rules for allow traffic from ANSIBLE to mysql
# resource "aws_security_group_rule" "mysql_ansible" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   source_security_group_id = module.ansible_sg.id   
#   security_group_id = module.mysql_sg.id 
# }

#Create Security group rules for allow traffic from ANSIBLE to backend
resource "aws_security_group_rule" "backend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible_sg.id   
  security_group_id = module.backend_sg.id 
}

#Create Security group rules for allow traffic from ANSIBLE to backend
resource "aws_security_group_rule" "frontend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible_sg.id   
  security_group_id = module.frontend_sg.id 
}

#Create Security group rules for allow traffic from public to ANSIBLE
resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
  security_group_id = module.ansible_sg.id 
}


#Create BACKEND Security Group
module "app_alb_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "app-alb"
    sg_tags = var.app_alb_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}

#Create Security group rules for allow traffic from app-alb to backend
resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.id   
  security_group_id = module.backend_sg.id 
}


#Create Security group rules for allow traffic from bastion to app-alb
resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.id   
  security_group_id = module.app_alb_sg.id 
}


#Create VPN SG. 22, 943, 443, 1194. all these are VPN port, should allow if we use VPN

module "vpn_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "vpn"
    sg_tags = var.vpn_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}


#22 VPN
resource "aws_security_group_rule" "vpn_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
  security_group_id = module.vpn_sg.id 
}

#443 VPN
resource "aws_security_group_rule" "vpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
  security_group_id = module.vpn_sg.id 
}

#943 VPN
resource "aws_security_group_rule" "vpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
  security_group_id = module.vpn_sg.id 
}

#1194 VPN
resource "aws_security_group_rule" "vpn_public_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
  security_group_id = module.vpn_sg.id 
}

#APP ALb accepting form VPN 80
resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id   
  security_group_id = module.app_alb_sg.id 
}

#BACKEND SERVER accepting form VPN_22
resource "aws_security_group_rule" "backend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id   
  security_group_id = module.backend_sg.id 
}

#BACKEND SERVER accepting form VPN_8080
resource "aws_security_group_rule" "backend_vpn_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id   
  security_group_id = module.backend_sg.id 
}


#Create WEB ALB Security Group
module "web_alb_sg" {
    source = "git::https://github.com/aikdp/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "web-alb"
    sg_tags = var.web_alb_sg_tags
    vpc_id = local.vpc_id   #get it from data source, we already store at ssm parameter
}


#WEB ALB accepting form Public http 80
resource "aws_security_group_rule" "web_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]   
  security_group_id = module.web_alb_sg.id 
}

#WEB ALB accepting form Public HTTPS 443
resource "aws_security_group_rule" "web_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]   
  security_group_id = module.web_alb_sg.id 
}



#FRONTNED

#Create Security group rules for allow traffic from VPN to frontend
resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.id  
  security_group_id = module.frontend_sg.id 
}

#Create Security group rules for allow traffic from web albto frontend
resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb_sg.id  
  security_group_id = module.frontend_sg.id 
}


#Create Security group rules for allow traffic from frontend to App ALB
resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend_sg.id  
  security_group_id = module.app_alb_sg.id 
}