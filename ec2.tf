
# Create VPC
# Create subnet
# Create security group
# 

provider "aws" {
    region = "ap-south-1"
    profile = "sanjay.baskar"
}

# create default vpc if no one exist

resource "aws_default_vpc" "aws_default_vpc" {
    tags = {
        Name   = "default vpc"
    }
}

# use data source to get all availability zones in region 

data "aws_availability_zones" "availability_zones"{}

# Create default subnet if one does not exit

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.availability_zones.names[0]

  tags = {
    Name = "Default subnet"
  }
}

# create security group for the Ec2 instance

resource "aws_security_group" "ec2_security_group" {
  name = "Ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id = aws_default_vpc.aws_default_vpc.id
  
}

# allow access on port 8080

ingress{
    description = "http proxy access"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

# allow access on port 22

ingress{
    description = "ssh access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

egress{
  from_port= 0
  to_port= 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Name = "jenkins server security group"
  }
}

# use data source to get a registered amazon linux 2 ami

data "aws_ami" "amazon_linux_2"{
  most_recent = true
  owners = ["amazon"]

  filter{
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    {
      name = "name"
      values = ["amzn2-ami-hvm"]
    }
  }
}

# launch the EC2 instance and install website

resource "aws_instance" "ec2_instance"{
  ami = data.aws_ami.amazon_linux_2.vpc_id
  instance_type = "t2.micro"
  subnet_id = aws_default_subnet.default_az1.id 
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name = "Jenkinskey"
  # user_data = file("install_jenkins.sh")

  tags = {
    Name = "Jenkins server"
  }
}

# an empty resource block

resource "null_resource" "name" {

  # ssh into the ec2 instance
  connection{
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/Downloads/Jenkinskey.pem")
    host = aws_instance.ec2_instance.public_ip
  }
}

# copy the install_jenkins.sh file from your computer to the ec2 instance

provisioner "file" {
  source = 

}