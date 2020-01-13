provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
resource "aws_eip" "nat" {
  count = 3
  vpc = true
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "dev-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets = ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
  private_subnets  = ["10.0.10.0/23", "10.0.12.0/23", "10.0.14.0/23"]
  enable_nat_gateway = true
  single_nat_gateway  = false
  reuse_nat_ips       = true  
  external_nat_ip_ids = "${aws_eip.nat.*.id}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    sredevops = "true"
    Environment = "dev"
    sre_candidate= "tochukwu.nwoko"
  }
}
resource "aws_security_group" "elb-sg" {
  name        = "elb-sg"
  description = "Allow http/s traffic from the internet and forward to wordpress instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ## whole internet
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ## whole internet
  }
  tags = {
    sre_candidate= "tochukwu.nwoko"
  }
}

resource "aws_security_group" "django_instance" {
  name        = "django-instance-sg"
  description = "Allow http traffic from load balancer"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks =["0.0.0.0/0"]
  }

  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
resource "aws_security_group" "bastian_instance" {
  name        = "bastian-instance-sg"
  description = "Allow  SSH Traffic"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
resource "aws_security_group" "rd_database" {
  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
  name        = "rd-database-sg"
  description = "Allow http traffic from instance"
  vpc_id      = module.vpc.vpc_id

}
resource "aws_security_group_rule" "django-instance-from-load-balancer" {
  description = "Accept traffic from load balancer security group"

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = aws_security_group.django_instance.id
  source_security_group_id = aws_security_group.elb-sg.id
}

resource "aws_security_group_rule" "django-load-balancer-to-instance" {

  description = "Send traffic from load balancer to instance security group"

  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = aws_security_group.elb-sg.id
  source_security_group_id = aws_security_group.django_instance.id
}
resource "aws_security_group_rule" "django-instance-from-load-balancer-https" {
  description = "Accept traffic from load balancer security group"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id        = aws_security_group.django_instance.id
  source_security_group_id = aws_security_group.elb-sg.id
}

resource "aws_security_group_rule" "django-load-balancer-to-instance-https" {

  description = "Send traffic from load balancer to instance security group"

  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id        = aws_security_group.elb-sg.id
  source_security_group_id = aws_security_group.django_instance.id
}
resource "aws_security_group_rule" "django-database-from-instance" {

  description = "Accept traffic from instance security group"

  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"

  security_group_id        = aws_security_group.rd_database.id
  source_security_group_id = aws_security_group.django_instance.id
}
resource "aws_security_group_rule" "allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_group_id = aws_security_group.django_instance.id
  source_security_group_id = aws_security_group.bastian_instance.id 
}
resource "aws_security_group_rule" "allow_ssh-egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  security_group_id = aws_security_group.bastian_instance.id
  source_security_group_id = aws_security_group.django_instance.id 
}
data "aws_ami" "django-ami" {
   filter {
     name   = "name"
     values = ["ubuntu-*"]
   }
   owners=["amazon"]

   most_recent = true
 }


resource "aws_key_pair" "bastian" {
  key_name   = "bastian"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBQy6DQGcoj6DAlD235BC4Izj03o2BE8e8piBeULQRg3moge8+R1IX53qfhWkWRwuBGnoMvdU5XHAgm6BIcZlS+49dtVEzP/+1SBOhUplbuK1UDTkFGv436v4KqERdr5T5t5cr4kyyvF5a8AxGWzYWTGt0sqJvxBVs3SRcIQsbtqfn7xOl20ZGI6DNbJWAtIGdevvgZlFQ1up7ObGLi2WcfAbplNAajgLWundnV7DdjNOFqsIyhgorTpCEiDToPKhINzMq9n2g51R+cfeGjPL+TqXQyN7O1OtA42J1+V1+QSRJ5WovcalmLNxohhXGAXQPsRC04PAVkwQcHztfxftpbNKm7ftzrrtMFTZe1aDrDgWKP61n9a4jDJzi4rLyHj5Qk/fSjXKyAaSRKBq3RlDnxi5cqe6Pjr3AeV5m88aa9/FmoZOlD2+EZz8pJIuLBi6ktxzkRkoBwEe3mvDmXCUg/67YHyzvM0QGkXrM67Rp+T8Awk7MYeh/tOj7iWPB5IbG83G1EiHcwRQD6itmQqypNiByNjuoaJ8hFS/eH+KRw/NPX0+nJNQg2914/llQWAMXuXUnQib/JBzVZRqCOHjRUGI9QI5lU2rS1xMN3lpNrnVo1zWWESCtF8c1pKKGachwWdoIm36mQoebNSSZB/KkoeT7PcXuV+oiQxZ8B/MBAw== nwokotochukwu@gmail.com"
}

resource "aws_instance" "bastian" {
  ami           = data.aws_ami.django-ami.id
  instance_type = "t2.micro"
  key_name = "bastian"
  subnet_id = module.vpc.public_subnets.1
  vpc_security_group_ids = [aws_security_group.bastian_instance.id]
  associate_public_ip_address = true 

  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
resource "aws_instance" "django-1" {
  ami           = data.aws_ami.django-ami.id
  instance_type = "t2.micro"
  subnet_id = module.vpc.private_subnets.1
  vpc_security_group_ids = [aws_security_group.django_instance.id]
  associate_public_ip_address = false
  key_name= "bastian"
  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
resource "aws_instance" "django-2" {
  ami           = data.aws_ami.django-ami.id
  instance_type = "t2.micro"
  subnet_id = module.vpc.private_subnets.2
  vpc_security_group_ids = [aws_security_group.django_instance.id]
  associate_public_ip_address = false
  key_name = "bastian"

  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
resource "aws_instance" "django-3" {
  ami           = data.aws_ami.django-ami.id
  instance_type = "t2.micro"
  subnet_id = module.vpc.private_subnets.0
  vpc_security_group_ids = [aws_security_group.django_instance.id]
  associate_public_ip_address = false
  key_name= "bastian"
  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
#data "aws_subnet_ids-2" "example" {
 # vpc_id = "vpc-043899f075e330100

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["subnet-0676c5f47b8707284", "subnet-0f9522f2b909e8beb", "subnet-073a10c933af23409"]

  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  vpc_security_group_ids = [aws_security_group.rd_database.id, aws_security_group.django_instance.id]
  multi_az = true
  tags = {
    sre_candidate = "tochukwu.nwoko"
  }
}
