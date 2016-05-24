# This file contains default variabled that are shared by all environments

variable "account_id" {
    description = "AWS Account ID"
    default = "154007893214"
}

variable "ssh_pub_key_bucket" {
    description = "Name of the S3 bucket for SSH public keys"
    default = "moz-mozreview-keys"
}

variable "ssh_key_names" {
    description = "List of SSH pub keys to manage in S3 bucket"
    default = "klibby@mozilla.com,jwatkins@mozilla.com"
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

variable "centos6_amis" {
    description = "Centos 6 (x86_64) with Updates HVM, rel 02/26/2016"
    type = "map"
    default = {
        us-east-1 = "ami-1c221e76"
        us-west-1 = "ami-ac5f2fcc"
        us-west-2 = "ami-05cf2265"
    }
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

# These availablity zones are specific to the mozreview account
# In the future, this may be dynamically determined
variable "availablity_zones" {
    description = "A list of availablity zones per US region"
    type = "map"
    default = {
        us-east-1 = "us-east-1a,us-east-1b,us-east-1d,us-east-1e"
        us-west-1 = "us-west-1b,us-west-1c"
        us-west-2 = "us-west-2a,us-west-2b,us-west-2c"
    }
}
