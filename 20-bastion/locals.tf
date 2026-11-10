locals {
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
}

data "aws_ami" "joindevops" {
    most_recent       = true
    owners            = ["973714476881"]
    filter {
        name   = "name"
        values = ["Redhat-10-DevOps-Practice"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}