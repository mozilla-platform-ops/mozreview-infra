variable "env" {
    description = "Name of the product/envrionment"
}

variable "vpc_cidr" {
    description = "CIDR block to assign to mozreview vpc"
}

variable "web_instance_type" {
    description = "EC2 instance type of Mozreview web ec2 instances"
}

variable "web_subnets" {
    description = "List of subnets for Mozreview web ec2 instances"
}

variable "web_azs" {
    description = "List of availablity zones to be matched with the web subnet list"
}

variable "web_ami_id" {
    description = "AMI ID for Mozreview web ec2 instances"
}

variable "web_instances_per_subnet" {
    description = "Number of web ec2 instances per web subnet"
}

variable "web_instance_profile" {
    description = "Instance profile for Mozreview web ec2 instances"
}

variable "elb_subnets" {
    description = "List of subnets for loadbalancer distribution"
}

variable "elb_azs" {
    description = "List of availablity zones to be matched with the elb subnet list"
}

variable "rds_subnets" {
    description = "List of subnets for database instances distribution"
}

variable "rds_azs" {
    description = "List of availablity zones to be matched to the rds subnet list"
}

variable "rds_instance_class" {
    description = "RDS instances class type"
}

variable "logging_bucket" {
    description = "S3 logging bucket"
}

variable "memcached_instance_type" {
    description = "Instance type for memcached instances"
}

variable "elc_subnets" {
    description = "List of subnets for memcached instances distribution"
}

variable "elc_azs" {
    description = "List of availablity zones to be matched to the elc subnet list"
}

variable "num_memcached_nodes" {
    description = "Total number of memcached nodes"
}

variable "allow_bastion_sg" {
    description = "Security group to allow bastion host access"
}

variable "peer_vpc_id" {
    description = "Bastion host vpc id"
}

variable "peer_route_table_id" {
    description = "Bastion host route table"
}

variable "peer_cidr_block" {
    description = "Bastion host vpc CIDR block"
}

variable "peer_account_id" {
    description = "Bastion host account number"
}
