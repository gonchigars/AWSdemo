provider "aws" {
  region = "us-east-1" # Specify the region (N. Virginia)
}

# Variables for customization
variable "instance_type" {
  default = "t2.micro" # Default instance type
}

variable "ami_id" {
  type    = string
  default = "ami-066784287e358dad1" # Amazon Linux 2 AMI ID
}

variable "key_name" {
  default = "lab_key_pair"
}

# Create a Key Pair
resource "tls_private_key" "lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "lab_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.lab_key.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.lab_key.private_key_pem
  sensitive = true
}

# Create a VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "LabVPC"
  }
}

# Create a Subnet
resource "aws_subnet" "lab_subnet" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "LabSubnet"
  }
}

# Create a Security Group
resource "aws_security_group" "lab_sg" {
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LabSecurityGroup"
  }
}

# Create an EC2 Instance
resource "aws_instance" "lab_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id] # Use vpc_security_group_ids instead of security_groups
  key_name      = aws_key_pair.lab_key_pair.key_name

  tags = {
    Name = "LabInstance"
  }
}

