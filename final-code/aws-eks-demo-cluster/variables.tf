variable "region" {}
variable "cluster_name" {}
variable "instance_types" {}
variable "public_subnet_1_cidr" {}
variable "public_subnet_2_cidr" {}
variable "private_subnet_1_cidr" {}
variable "private_subnet_2_cidr" {}
variable "vpc_cidr" {}
variable "cluster_version" {}
variable "accountid" {}
variable "alb_certificate_arn" {}
variable "app_image" {
  description = "Docker image for the application"
  type        = string
}