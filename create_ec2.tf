variable "iam_user" {
  description = "IAM user who is running the Terraform for tag gating"
  type        = string
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "example" {
  name        = "example"
  vpc_id      = "vpc-0d37795e836c9b84d"

  tags = {
    IAMUser = var.iam_user
  }
}

# Ingress security group rule for SSH
resource "aws_security_group_rule" "example_ingress_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.example.id
}

# Egress security group rule to allow all outbound traffic
resource "aws_security_group_rule" "example_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.example.id
}

resource "random_string" "key_pair_name" {
  length           = 10
  special          = false
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-deployer-${random_string.key_pair_name.result}"
  public_key = file("${path.module}/ssh_keys/deployer-key.pub")

  tags = {
    IAMUser = var.iam_user
  }
}

resource "aws_instance" "example_instance" {
  ami                    = "ami-09ac7e749b0a8d2a1" # Amazon Linux 2023 AMI
  instance_type          = "t3a.nano"
  vpc_security_group_ids = [aws_security_group.example.id]
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = "subnet-07c511249980f30fb" #lab uw2a

  tags = {
    IAMUser = var.iam_user
  }
}

output "instance_metadata" {
  value = {
    instance_id = aws_instance.example_instance.id
    private_ip  = aws_instance.example_instance.private_ip
  }
  description = "Metadata of the created EC2 instance."
}

# Example SSH Command: 
# ssh -i ./ssh_keys/deployer-key ec2-user@<private_ip>