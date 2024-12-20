#1.Create frontend instance
module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops.id
  name = local.resource_name

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.frontend_sg_id]
  subnet_id              = local.public_subnet_id

  tags = merge(
    var.common_tags,
    var.frontend_tags,
        {
          Name = local.resource_name
        }
  )
}

#2.Create NUll resource to run Ansible playbook through remote provisioner.
#The null_resource resource implements the standard resource lifecycle but takes no further action.
resource "null_resource" "frontend" {
  # Changes to id of instance tehn requires re-provisioning
  triggers = {
    instance_id = module.frontend.id     #means when frontend instance id creates, then only it will trigger apply
  }

  # So we just choose the first in this case
  connection {
    host = module.frontend.private_ip    #to connect frontend instance
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "${var.frontend_tags.Component}.sh"    #frontend.sh
    destination = "/tmp/frontend.sh"     #frontend.sh file copies to tmp folder
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/frontend.sh",   #modifying permision
      "sudo sh /tmp/frontend.sh ${var.frontend_tags.Component} ${var.environment}"    #sudo sh /tmp/frontend.sh frontend dev (#arg1 agr2)
    ]
  }
}


#3.Stop ec2 instance
resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.frontend.id
  state       = "stopped"
  depends_on = [null_resource.frontend]     # If we apply, terraform automatically run all resources parallelly right. So put depends_on. Then it will only runs once the previous one completed
}


#4.Create AMI from stopped instances
resource "aws_ami_from_instance" "frontend" {
  name               = local.resource_name
  source_instance_id = module.frontend.id
  depends_on = [aws_ec2_instance_state.frontend]
}


#5.Delete the instance using NULL RESOURCE, beacuse DELETE option for insatnce is not there.
resource "null_resource" "frontend_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.frontend.id
  }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.frontend.id}"
    # command = "aws ec2 terminate-instances --instance-ids ${instance_id}"

    # environment = {
    #   instance_id = module.frontend.id
    # }
  }

  depends_on = [aws_ami_from_instance.frontend]
}



#6. Create TARGET GROUP for app alb
resource "aws_lb_target_group" "frontend" {
  name        = local.resource_name
  port        = 80  #should be  80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id

  health_check {    
    healthy_threshold = 2   #No. of consecutive health check success required 
    unhealthy_threshold = 2
    interval = 5    
    matcher = "200-299"
    path = "/"    #not health  
    port = 80
    protocol = "HTTP"
    timeout = 4
  }
}

#7. Create Launch template.  Can be used to create instances or auto scaling groups.
resource "aws_launch_template" "frontend" {
  name = local.resource_name

  image_id = aws_ami_from_instance.frontend.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  vpc_security_group_ids = [local.frontend_sg_id]

  #subnet = local.priavte_subnet_ids    #removed, We can see in Auto scaling Group .I think subnet will be in Network interface block.

#    network_interfaces {
#     associate_public_ip_address = true
#   }

  update_default_version = true     #every time update version

  tag_specifications {  #here it is TAG only
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }

}


#8. Create Auto Scaling Groups ASG
resource "aws_autoscaling_group" "frontend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
#   force_delete              = true    3commenting it
  
  target_group_arns = [aws_lb_target_group.frontend.arn]     #we need to tell which place instances should create

  launch_template {                         #provide launch template here
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  vpc_zone_identifier       = [local.public_subnet_id]

  instance_refresh {        #provide instance refresh block when lanch template, refresh instance
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]  #A refresh will always be triggered by a change in any of launch_configuration, launch_template, or mixed_instances_policy.
  }

#   instance_maintenance_policy {
#     min_healthy_percentage = 90
#     max_healthy_percentage = 120
#   }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

 # If instances are unhealthy with in 15min, autoscaling will delete that instance
  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "Expense"
    propagate_at_launch = false
  }
}

#9. Create Auto Scaling policy
resource "aws_autoscaling_policy" "frontend" {
  # ... other configuration ...
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  name                   = local.resource_name
  policy_type            = "TargetTrackingScaling"  #eqivalent to manually craeting asg policy for cpu utilization

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

#10. Craete ALb Listener Rule
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = local.web_alb_listener_arn
  priority     = 100    #low priority evaluted first

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["${var.project_name}-${var.environment}.${var.zone_name}"]        #expense-dev.telugudevops.online
    }
  }
}