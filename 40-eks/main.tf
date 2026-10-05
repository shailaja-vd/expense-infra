resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZvWdYhK/HbfTXQAHIxiAsBnzdEKN49HXg7jj7jsZk0oFX6Dh6dbiXOjXdMpvVQrSzxyEFZPEt4kdyYxvLng2tzqo7D/pGqveRSpNemw60fdBxNAIWymZ6Xnp4rc6vKdSVbH8M0sGTqoKdmYNcdCAoLIGrp6P+Tzu4+b47fQpdfqw8IeW8iXCc98z37KWhHT11XgsaacR2bF2txVlKbIjsRn0IJhe+VPx0xCDAH0kuSSnFS+NOagqPRtmjbEXisEJPhYBb00L8qwMjZszP26sB2GaubnVM/s4Jg00XCbu8tPYJAF3Lt+U+oLSHBvU3Mn+TTZYv/D9JOnOb7VCfo5LAysK9RrYAZjUXzhhRCFT5qzCtjC5cWcXPwA7fRJnoFzbAd3xlkRNWSL71pOvLMPOTAPowrEfPaoc/X3bGCn7AShxwp5JNJxZkbQB51uyFJxIsElJvVBlwSJNJJQ+y9TZG3bC1J01UIFS4luk+/XRHhxAC1OzvMHWWlHN9opZ5Tlc= DELL@sadaiah"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.31" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["c3.large", "c4.large", "c5.large", "c5d.large", "c5n.large", "c5a.large", "t3.small"]
     capacity_type = "SPOT"
  }

  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["t3.small"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}