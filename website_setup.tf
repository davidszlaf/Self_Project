# Define the AWS provider
provider "aws" {
  region = "eu-central-1" 
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Create subnet
resource "aws_subnet" "public" {
  vpc_id                  = vpc-0d84b6be205e562f0
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1" 
  map_public_ip_on_launch = true
}

# Create Security Group
resource "aws_security_group" "web_sg" {
  name = "web_sg"
  vpc_id = vpc-0d84b6be205e562f0

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = vpc-0d84b6be205e562f0
  
  tags = {
    Name = "allow_tls"
    }
  }
  
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  }
  
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
  }
  
}


# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.name]

  # Configure a basic web server
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF
}
