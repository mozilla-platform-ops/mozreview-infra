provider "aws" {
    profile = "${var.profile}"
    region  = "${var.region}"
}

# Enable Cloudtrail logging to S3 bucket local to account
module "cloudtrail" {
    source = "github.com/mozilla-platform-ops/tf_aws_cloudtrail"
    version = "v1.0.1"
    account_id = "${var.account_id}"
    bucket_name = "${var.cloudtrail_bucket}"
}

