#!/bin/bash


#this script will need to run in backend serevr(instance)
#and also if script execution fails, we don't need that backend server right.

component=$1
env=$2

echo "Component: $component, Environment: $env"

dnf install ansible -y

ansible-pull -i localhost, -U https://github.com/aikdp/expense-ansible-tf-roles.git main.yaml -e component=$component -e environment=$env    #here -U is option url And Ansible-pull comma are syntax


