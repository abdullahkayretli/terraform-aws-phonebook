#we need 3 Security Groups
#1-Application Load Balancer
#2-Security Group for EC2 and auto-scale
#3-Security group for RDS


#1-Application Load Balancer
resource "aws_security_group" "alb-sg" {
  name        = "ALB-Sec-Group"
  description = "Security Group for Application Load Balancer"
  vpc_id      = data.aws_vpc.def-vpc.id
  tags = {
    Name = "TF-ALB-Sec-Group"
  }
  ingress {
    description      = "Allow port 80 inbound traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"] 
  }   
}


#2-Security Group for EC2 and auto-scale
resource "aws_security_group" "server-sg" {
name        = "WebServer-Sec-Group"
description = "Security Group for web servers -EC2s- and auto-scale"
vpc_id      = data.aws_vpc.def-vpc.id
tags = {
  Name = "TF-WebServer-Sec-Group"
  }
  ingress {
    description      = "Allow port 80 inbound traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.alb-sg.id] //will accept the traffic via port 80 from Load balancer only
  }
  
  ingress {
    description      = "Allow port 22 inbound traffic for SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]    
  }   
}


#3-Security group for RDS
resource "aws_security_group" "db-sg" {
name        = "RDS-Sec-Group"
description = "Security Group for RDS"
vpc_id      = data.aws_vpc.def-vpc.id
tags = {
  Name = "TF-RDS-Sec-Group"
  }
  ingress {
    description      = "Allow port 3306 inbound traffic for RDS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [aws_security_group.server-sg.id]  #will accept the traffic via port 3306 from servers only
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]    
  }  
}