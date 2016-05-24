variable "name" {
    default = "mozreivew"
}

variable "env" {}
variable "vpc_cidr" { }

variable "web_instance_type" {}
variable "web_subnets" {}
variable "web_azs" {}
variable "web_name" {}
variable "web_ami_id" {}
variable "number_of_instances" {}

variable "elb_subnets" {}
variable "elb_azs" {}


variable "user_data" {
    default = ""
}
