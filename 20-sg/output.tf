output "mysql_sg_id" {
  value       = module.mysql_sg.id
}

output "backend_sg_id" {
  value       = module.backend_sg.id
}

output "frontend_sg_id" {
  value       = module.frontend_sg.id
}

output "bastion_sg_id" {
  value       = module.bastion_sg.id
}

output "ansible_sg_id" {
  value       = module.ansible_sg.id
}

output "vpn_sg_id" {
  value       = module.vpn_sg.id
}
