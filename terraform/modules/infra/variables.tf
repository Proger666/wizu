# General Infrastructure Variables
variable "environment" {
  description = "The environment for the infrastructure (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "installation_region" {
  description = "Region where resources will be deployed"
  type        = string
  default     = "us-east-2"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "very-cracking-vpc"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for VPC subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway in the VPC"
  type        = bool
  default     = false
}

# EC2 Database Configuration
variable "ssh_key_pair_name" {
  description = "Default EC2 ssh key-pair name"
  type        = string
}
# Database Configuration
variable "database_hostname" {
  description = "The hostname to be used in naming resources for the database"
  type        = string
  default     = "db-instance"
}

variable "database_instance_type" {
  description = "The EC2 instance type for the database server"
  type        = string
  default     = "t3.micro"
}


variable "database_allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the database EC2 instance via SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "database_username" {
  description = "Username for the MongoDB database"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Password for the MongoDB database"
  type        = string
  sensitive   = true
}

# EKS Configuration
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "eks_cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "eks_node_instance_type" {
  description = "Instance type for EKS managed node groups"
  type        = string
  default     = "t3.small"
}

# Docker Image Configuration for Web Application
variable "web_app_image" {
  description = "Docker image for the web application"
  type        = string
  default     = "jeffthorne/tasky:latest"
}

# IAM Role and Permissions
variable "enable_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for the cluster creator"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "crackme"
}
