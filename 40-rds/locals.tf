locals {
  resource_name = "${var.project_name}-${var.environment}"      #expense-dev
  mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
  database_subnet_group_name = data.aws_ssm_parameter.database_subnet_group_name.value
  # db_subnet_ids = data.aws_ssm_parameter.database_subnet_ids.value
}

  # db_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids[*].value)