resource "aws_instance" "this" {
  ami                    = "ami-0220d79f3f480ecf5" #This is our devops-practice AMI ID
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id = local.public_subnet_id

  # 20GB is not enough
  root_block_device {
    volume_size = 50 # set root volume size to 50GB
    volume_type = "gp3" # Use gp3 for better performance (optional)
  }
  user_data = file("bastion.sh")
  
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}
