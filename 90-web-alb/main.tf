#Create Web Apllication Load balancer
module "web_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${local.resource_name}-web-alb"      #expense-dev-app-alb
  vpc_id  = local.vpc_id
  subnets = local.public_subnet_id               #app-alb is for backend, so we rae using Private subnet (AZ)
  internal = false            #default is false. giving to public access, it is public right
  security_groups = [local.web_alb_sg_id]    # LIST sg is giving for ALB eqyalent to manually selecing sg id.
  create_security_group = false        #defalut is true, if not give flase, it will take default sg id
  enable_deletion_protection = false            #put this false, it will dlete, otherwise not delete
  tags = merge(
    var.common_tags,
    var.web_alb_tags
  )
}


#Creating WEB ALB listener using TERRAFORM

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.web_alb.arn    #check o/p attribute    arn--endpoint id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, iam from HTTP WEB Load Balancer</h1>"
      status_code  = "200"
    }
  }
}

#Create WEB ALB HTTPS listener 
resource "aws_lb_listener" "https" {
  load_balancer_arn = module.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_certificate_arn   #need to provide certificate arn if we take 443 in listener
  # alpn_policy       = "HTTP2Preferred"


  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from WEB ALB HTTPS</h1>"
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
      name    = "expense-${var.environment}"  # expense-dev
      type    = "A"
      alias = {
        name =  module.web_alb.dns_name
        zone_id =  module.web_alb.zone_id    # This belongs ALB internal hosted zone, not ours
      }
      allow_overwrite = true
    }
  ]
}