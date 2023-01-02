data "aws_vpc" "def-vpc" {
  default = true
}

data "aws_subnets" "pub-sub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.def-vpc.id]
  }
}

data "aws_ami" "baseami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}