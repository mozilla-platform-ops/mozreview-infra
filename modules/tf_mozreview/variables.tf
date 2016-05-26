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
variable "memcached_instance_type" {}
variable "elc_subnets" {}
variable "elc_azs" {}
variable "num_memcached_nodes" {}
variable "allow_bastion_sg" {}


variable "peer_vpc_id" {}
variable "peer_route_table_id" {}
variable "peer_cidr_block" {} 
variable "peer_account_id" {}
