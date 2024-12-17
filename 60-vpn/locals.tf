locals {
  resource_name = "${var.project_name}-${var.environment}-vpn"      #expense-dev
  vpn_sg_id = data.aws_ssm_parameter.vpn_sg_id.value
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
}

  # db_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids[*].value)