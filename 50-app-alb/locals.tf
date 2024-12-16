locals {
  resource_name = "${var.project_name}-${var.environment}"      #expense-dev
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  app_alb_sg_id = data.aws_ssm_parameter.app_alb_sg_id.value
}

  # db_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids[*].value)