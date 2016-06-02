variable "env" {
    description = "Name of the product/environment"
}

variable "vpc_cidr" {
    description = "CIDR block for vpc"
}

variable "instance_type" {
    description = "Instance type for autoland ec2 instances"
}

variable "subnets" {
    description = "Subnets for autoland ec2 instances"
}

variable "azs" {
    description = "Availablity zones to be matched to subnets"
}

variable "ami_id" {
    description = "Autoland ec2 instance AMI"
}

variable "instance_profile" {
    description = "Autoland ec2 instance profile"
}

variable "allow_bastion_sg" {
    description = "Security Group to allow ssh from bastion host"
}

variable "peer_vpc_id" {
    description = "Bastion host VPC ID"
}

variable "peer_route_table_id" {
    description = "Bastion host route table"
}

variable "peer_cidr_block" {
    description = "Bastion host VPC CIDR block"
}

variable "peer_account_id" {
    description = "Bastion host account ID"
}

variable "user_data_bucket" {
    description = "S3 bucket containing user-data scripts"
}

variable "addl_user_data" {
    description = "List of user-data scripts in user-data bucket for Autoland ec2 instances"
}
