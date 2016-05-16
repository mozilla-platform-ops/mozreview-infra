provider "aws" {
    profile = "${var.profile}"
    region  = "${var.region}"
}

# Enable Cloudtrail logging to S3 bucket local to account
module "cloudtrail" {
    source = "../modules/cloudtrail"
    account_id = "${var.account_id}"
    bucket_name = "${var.cloudtrail_bucket}"
}

