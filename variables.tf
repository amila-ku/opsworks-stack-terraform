variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

# ubuntu-trusty-14.04 (x64)
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-5f709f34"
    "us-west-2" = "ami-7f675e4f"
  }
}

variable "availability_zones" {
  default     = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "server_certificate" {
  description = "SSL certificate to use"
  default = "arn:aws:iam::880935311111:server-certificate/domain"
}

variable "isInternal" {
  description = "Set value to create public ELB or a private ELB, false to create public ELB"
  default = "false"
}

variable "access_key" {
  default = "access_key_name"
}

variable "region_s" {
  default = "usw2"
}

variable "vpc_details" {
  default = "vpc-xxx"
}

variable "env" {
  description = "Defines the environment"
  default = "dev"
}

variable "apptype" {
  description = "application type" 
  default = "api"
}

variable "app_details" {
  description = "application details"
  default = "data services api, running jetty"
}



variable "prv_key" {
  default = "/home/terraform/.ssh/pwa_access.pem"
}
