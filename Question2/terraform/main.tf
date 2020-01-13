module "eks" {
  source  = "WesleyCharlesBlake/eks/aws"

  aws-region          = "eu-west-1"
  availability-zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  cluster-name        = "my-cluster"
  k8s-version         = "1.14"
  node-instance-type  = "t3.medium"
  root-block-size     = "40"
  desired-capacity    = "3"
  max-size            = "5"
  min-size            = "1"
  public-min-size     = "2" # setting to 0 will create the launch config etc, but no nodes will deploy"
  public-max-size     = "4"
  public-desired-capacity = "2"
  vpc-subnet-cidr     = "10.0.0.0/16"
  private-subnet-cidr = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public-subnet-cidr  = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
  db-subnet-cidr      = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"]
  eks-cw-logging      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  #ec2-key-public-key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
  ec2-key-public-key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBQy6DQGcoj6DAlD235BC4Izj03o2BE8e8piBeULQRg3moge8+R1IX53qfhWkWRwuBGnoMvdU5XHAgm6BIcZlS+49dtVEzP/+1SBOhUplbuK1UDTkFGv436v4KqERdr5T5t5cr4kyyvF5a8AxGWzYWTGt0sqJvxBVs3SRcIQsbtqfn7xOl20ZGI6DNbJWAtIGdevvgZlFQ1up7ObGLi2WcfAbplNAajgLWundnV7DdjNOFqsIyhgorTpCEiDToPKhINzMq9n2g51R+cfeGjPL+TqXQyN7O1OtA42J1+V1+QSRJ5WovcalmLNxohhXGAXQPsRC04PAVkwQcHztfxftpbNKm7ftzrrtMFTZe1aDrDgWKP61n9a4jDJzi4rLyHj5Qk/fSjXKyAaSRKBq3RlDnxi5cqe6Pjr3AeV5m88aa9/FmoZOlD2+EZz8pJIuLBi6ktxzkRkoBwEe3mvDmXCUg/67YHyzvM0QGkXrM67Rp+T8Awk7MYeh/tOj7iWPB5IbG83G1EiHcwRQD6itmQqypNiByNjuoaJ8hFS/eH+KRw/NPX0+nJNQg2914/llQWAMXuXUnQib/JBzVZRqCOHjRUGI9QI5lU2rS1xMN3lpNrnVo1zWWESCtF8c1pKKGachwWdoIm36mQoebNSSZB/KkoeT7PcXuV+oiQxZ8B/MBAw== nwokotochukwu@gmail.com"
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}

output "config-map" {
  value       = module.eks.config-map
  description = "K8S config map to authorize"
}
output "publicips" {
    value = "${module.eks.public_ips}"
}
output "privateips" {
  value = module.eks.privateips
}
output "policy" {
  value = module.eks.policy
}