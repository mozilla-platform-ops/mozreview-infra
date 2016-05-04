# This file contains default variabled that are shared by all environments

variable "account_id" {
    description = "AWS Account ID"
    default = "154007893214"
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
