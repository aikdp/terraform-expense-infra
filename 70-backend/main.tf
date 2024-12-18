#Create backend instance
module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.devops.id
  name = local.resource_name

  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.backend_sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(
    var.common_tags,
    var.backend_tags,
        {
          Name = local.resource_name
        }
  )
}

#Create NUll resource to run Ansible playbook through remote provisioner
resource "null_resource" "backend" {
  # Changes to id of instance tehn requires re-provisioning
  triggers = {
    instance_id = module.backend.id     #means when backend instance id creates, then only it will apply
  }

  # So we just choose the first in this case
  connection {
    host = module.backend.private_ip    #to connect backend instance
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "${var.backend_tags.Component}.sh"    #backend.sh
    destination = "/tmp/backend.sh"     #backend.sh file copies to tmp folder
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh",   #modifying permision
      "sudo sh /tmp/backend.sh ${var.backend_tags.Component} ${var.environment}"    #sudo sh /tmp/backend.sh backend dev (#arg1 agr2)
    ]
  }
}


#Stop ec2 instance
resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  depends_on = [null_resource.backend]     # If we apply, terraform automatically run all resources parallelly right. So put depends_on. Then it will only runs once the previous one completed
}


#create AMI from stopped instances
resource "aws_ami_from_instance" "backend" {
  name               = local.resource_name
  source_instance_id = module.backend.id
  depends_on = [aws_ec2_instance_state.backend]
}


#Create NUll resource to delete the instance, beacuse DELETE option for insatnce is not there.
resource "null_resource" "backend_delete" {
  # Changes to id of instance tehn requires re-provisioning
  triggers = {
    instance_id = module.backend.id     
  }


  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
  }
  depends_on = [aws_ami_from_instance.backend]
}
