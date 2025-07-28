module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"  
  cluster_name    = "elk-kafka-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 2
      min_size     = 2

      instance_types = ["t3.large"]
    }
  }
}
