variable "name" {
    default = "mozreivew"
}

variable "env" {}
variable "vpc_cidr" { }

variable "web_instance_type" {}
variable "web_subnets" {}
variable "web_azs" {}
variable "web_instance_name" {}
variable "web_ami_id" {}
variable "web_instances_per_subnet" {}
variable "web_instance_profile" {}
variable "elb_subnets" {}
variable "elb_azs" {}
variable "rds_subnets" {}
variable "rds_azs" {}
variable "rds_instance_class" {}
variable "logging_bucket" {}
