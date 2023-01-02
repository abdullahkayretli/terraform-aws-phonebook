
resource "aws_launch_template" "server-lt" {
  name                   = "Server-Launch-Temp"
  image_id               = data.aws_ami.baseami.id
  instance_type          = "t2.micro"
  key_name               = "Your_Key.pem"
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  depends_on             = [github_repository_file.dbendpoint] #this resource block will be hold until github repository file block has been created
  user_data = filebase64("${path.module}/user-data.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServerofPhonebookApp-tf"
    }
  }
}


resource "aws_lb_target_group" "app-lb-tg" {
  name             = "lb-alb-tg-tf"
  port             = 80
  protocol         = "HTTP"
  vpc_id           = data.aws_vpc.def-vpc.id
  target_type      = "instance"
  protocol_version = "HTTP1"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    
  }
}

resource "aws_lb" "web-lb" {
  name               = "Web-Load-Balancer-tf"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = data.aws_subnets.pub-sub.ids
}



resource "aws_lb_listener" "app-listen" {
  load_balancer_arn = aws_lb.web-lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }
}

resource "aws_autoscaling_group" "ser-asg" {
  name                      = "Autoscaling-Servers-tf"
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         ="ELB"
  target_group_arns        =[aws_lb_target_group.app-lb-tg.arn]
  vpc_zone_identifier       = aws_lb.web-lb.subnets
  force_delete = true
  launch_template {
    id      = aws_launch_template.server-lt.id
    version = aws_launch_template.server-lt.latest_version
  }
}

resource "aws_db_instance" "db-server" {
  db_subnet_group_name = aws_db_subnet_group.SubGr.id
  depends_on = [aws_db_subnet_group.SubGr]
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  allocated_storage      = 20
  identifier             = "phonebook-app-db-tf"
  db_name                = "phonebook"
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "DB_Password1" #min 8 charecters
  monitoring_interval = 0
  multi_az               = false
  port                   = 3306
  publicly_accessible    = false
  skip_final_snapshot    = true
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  backup_retention_period = 0
  
}
resource "github_repository_file" "dbendpoint" {
  repository          = "phonebook"
  branch              = "main"
  file                = "dbserver.endpoint"
  content             = aws_db_instance.db-server.address #content will be pulled from db
  overwrite_on_create = true
}

resource "aws_db_subnet_group" "SubGr" {
  name       = "main"
  subnet_ids = data.aws_subnets.pub-sub.ids

  tags = {
    Name = "DB subnet group for RDS"
  }
}