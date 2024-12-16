#Create RDS:
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.resource_name

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "transactions"
  username = "root"
  manage_master_user_password = false   #default is true, here we are giving password
  password = "ExpenseApp1"
  port     = "3306"

  vpc_security_group_ids = [local.mysql_sg_id]
  skip_final_snapshot = true        #don't forgot add this line, if you want to destroy db
 
  tags =merge(
    var.common_tags,
    var.rds_tags,
  )

  # DB subnet group
  db_subnet_group_name = local.database_subnet_group_name

# # DB subnet group
#   create_db_subnet_group = true
#   subnet_ids             = [local.db_subnet_ids]

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

#Creating CNAME
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "${var.rds_tags.Component}-${var.environment}"  #mysql-dev
      type    = "CNAME"
      ttl     = 1
      records = [
       module.db.db_instance_address
      ]
      allow_overwrite = true
    },
  ]
}