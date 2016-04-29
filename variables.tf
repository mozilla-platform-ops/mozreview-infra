variable "account_id" {
    description = "AWS Account ID"
}
variable "profile" {
    description = "Name of the AWS profile to grab credentials from"
}
variable "bucket" {
    description = "Name of the S3 bucket for local cloudtrail logging"
}
variable "region" {
    description = "The AWS region to create things in."
    default = "us-west-2"
}
