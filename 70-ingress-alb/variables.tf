variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "domain_name" {
  default = "enjam.online"
}

variable "zone_id" {
  default = "Z0399733DGWR8DDRTBR4"
}