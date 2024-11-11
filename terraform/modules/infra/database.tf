# Security Group for Database EC2 Instance
locals {
}
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-${var.database_hostname}-db-sg"
  description = "Security group for ${var.database_hostname} EC2 instance"
  vpc_id      = module.vpc.vpc_id

  # Allow SSH access from specified CIDR blocks (public)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.database_allowed_ssh_cidr_blocks
  }

  # Allow database access only from within the VPC
  ingress {
    description = "Database access"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.database_hostname}-db-sg"
  }
}
resource "aws_instance" "db_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.database_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = var.ssh_key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.db_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.environment}-${var.database_hostname}-db-instance"
  }

  user_data = templatefile("${path.module}/scripts/db_setup.sh", {
    s3_bucket_name = module.backup_bucket.bucket_name
    region         = var.installation_region
  })
}

# Data Source for Latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}