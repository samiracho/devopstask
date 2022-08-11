variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region to create the infrastructure"
}

variable "instance_ami_id" {
  type        = string
  default     = "ami-0cc0a36f626a4fdf5"
  description = "The ami of the instance"
}

variable "instance_type" {
  type        = string
  default     = "t2.small"
  description = "The ami of the instance"
}

variable "environment" {
  type        = string
  default     = "common"
  description = "The name of the environment to setup"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "VPC CIDR"
}

variable "vpc_public_subnet_cidr" {
  type        = string
  default     = "10.10.0.0/24"
  description = "Subnet CIDR"
}

variable "vpc_public_subnet_az" {
  type        = string
  default     = "eu-central-1a"
  description = "Subnet availability zone"
}