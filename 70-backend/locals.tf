locals {
  resource_name = "${var.project_name}-${var.environment}-backend"      #expense-dev
  backend_sg_id = data.aws_ssm_parameter.backend_sg_id.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
}

  # db_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids[*].value)