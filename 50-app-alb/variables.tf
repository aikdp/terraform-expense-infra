variable "project_name"{
    default = "expense"
}

variable "environment"{
    default = "dev"
}

variable "common_tags"{
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "app_alb_tags"{
    default = {
        Component = "app-alb"
    }
}

variable "zone_name"{
    default = "telugudevops.online"
}