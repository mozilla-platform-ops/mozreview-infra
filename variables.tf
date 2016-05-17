# This file contains default variabled that are shared by all environments

variable "account_id" {
    description = "AWS Account ID"
    default = "154007893214"
}

variable "ssh_pub_key_bucket" {
    description = "Name of the S3 bucket for SSH public keys"
    default = "moz-mozreview-keys"
}

variable "tf_state_bucket" {
    description = "Name of the S3 bucket for Terraform remote state"
    default = "moz-mozreview-state"
}

variable "cloudtrail_bucket" {
    description = "Name of the S3 bucket for local cloudtrail logging"
    default = "moz-mozreview-logging"
}

variable "tf_state_file" {
    description = "Name of the Terraform remote state file"
    default = "terraform.tfstate"
}

variable "centos7_amis" {
    description = "Centos 7 (x86_64) with Updates HVM, rel 02/26/2016"
    type = "map"
    default = {
        us-east-1 = "ami-6d1c2007"
        us-west-1 = "ami-af4333cf"
        us-west-2 = "ami-d2c924b2"
    }
}

variable "centos6_amis" {
    description = "Centos 6 (x86_64) with Updates HVM, rel 02/26/2016"
    type = "map"
    default = {
        us-east-1 = "ami-1c221e76"
        us-west-1 = "ami-05cf2265"
        us-west-2 = "ami-ac5f2fcc"
    }
}
