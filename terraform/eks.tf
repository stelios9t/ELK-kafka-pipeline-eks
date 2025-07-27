module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"  
  cluster_name    = "elk-kafka-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    default = {
      desired_size = 1
      max_size     = 1
      min_size     = 1

      instance_types = ["t3.large"]
    }
  }
}
