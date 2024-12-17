#Create Apllicatrion Load balancer
module "app_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${local.resource_name}-app-alb"      #expense-dev-app-alb
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_id               #app-alb is for backend, so we rae using Private subnet (AZ)
  internal = true                                 #default is false. Not giving  public access, it is backend right
  security_groups = [local.app_alb_sg_id]         # LIST sg is giving for ALB eqyalent to manually selecing sg id.
  create_security_group = false                   #defalut is true, if not give flase, it will take default sg id
  enable_deletion_protection = false            #put this false, it will dlete, otherwise not delete
  tags = merge(
    var.common_tags,
    var.app_alb_tags
  )
}


#Creating Load Balancer listener using TERRAFORM

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.app_alb.arn    #check o/p attribute    arn--endpoint id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, iam from APPLICATION Load Balancer</h1>"
      status_code  = "200"
    }
  }
}

#Create RECORDS for Hostpath
#Creating CNAME
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "*.app-${var.environment}"  # *.app-dev.telugudveops.online
      type    = "A"
      alias = {
        name =  module.app_alb.dns_name
        zone_id =  module.app_alb.zone_id
      }
      allow_overwrite = true
    }
  ]
}