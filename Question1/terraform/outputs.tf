output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.bastian.public_dns
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.bastian.public_ip
}
output "private_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.django-2.private_ip
}
output "private_subnets_id" {
  value = "module.vpc.aws_subnet.public[0]"
}
