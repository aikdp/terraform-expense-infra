#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "mysql_sg_id" {
  name = "/${var.project_name}/${var.environment}/mysql_sg_id"
}

#Use SSM parameter to store in aws and get the info using data source
data "aws_ssm_parameter" "database_subnet_group_name" {
  name = "/${var.project_name}/${var.environment}/database_subnet_group_name"
}

# Use SSM parameter to store in aws and get the info using data source
# data "aws_ssm_parameter" "database_subnet_ids" {
#   name = "/${var.project_name}/${var.environment}/database_subnet_ids"
# }


