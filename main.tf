provider "aws" {
    profile = "${var.profile}"
    region  = "${var.region}"
}

# Enable Cloudtrail logging to S3 bucket local to account
module "cloudtrail" {
    source = "./cloudtrail"
    account_id = "${var.account_id}"
    bucket_name = "${var.cloudtrail_bucket}"
}

# Configure password policy
resource "aws_iam_account_password_policy" "strict" {
    minimum_password_length = 16
    require_lowercase_characters = true
    require_numbers = true
    require_uppercase_characters = true
    require_symbols = true
    allow_users_to_change_password = true
}

# Add admin group
resource "aws_iam_group" "admin-group" {
    name = "administrators"
}

# Attach MFA policy to admin group
resource "aws_iam_policy" "require_mfa-policy" {
    name = "require_mfa-policy"
    description = "Require use of Multifactor Authentication"
    policy = "${file("RequireMFA.json")}"
}
resource "aws_iam_policy_attachment" "require_mfa-attach" {
    name = "require_mfa-attach"
    groups = ["${aws_iam_group.admin-group.name}"]
    policy_arn = "${aws_iam_policy.require_mfa-policy.arn}"
}

# Attach AWS::AdministratorAccess policy to admin group
resource "aws_iam_policy_attachment" "admin_access-attach" {
    name = "admin_access-attach"
    groups = ["${aws_iam_group.admin-group.name}"]
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create bucket for remote state
resource "aws_s3_bucket" "tf_state-bucket" {
    bucket = "${var.tf_state_bucket}"
    acl = "private"
    #policy = ""
    versioning {
        enabled = true
    }
    logging {
        target_bucket = "${module.cloudtrail.bucket_id}"
        target_prefix = "s3/${var.tf_state_bucket}/"
    }
    tags {
        Name = "terraform state bucket"
    }
}

# Create an SNS topic for tf_state-bucket notifications
variable "tf_sns_topic_name" {
    description = "Hack to work around GH-4157"
    default = "tf_state_notifications"
}
resource "template_file" "bucket_sns-policy" {
    template = "${file("bucket_sns.json.tmpl")}"
    vars {
        region = "${var.region}"
        account_id = "${var.account_id}"
        topic_name = "${var.tf_sns_topic_name}"
        bucket_name = "${var.tf_state_bucket}"
    }
}
resource "aws_sns_topic" "tf_state_bucket-topic" {
    name = "${var.tf_sns_topic_name}"
    display_name = "tf-state"
    policy = "${template_file.bucket_sns-policy.rendered}"
}
# email protocol not supported, as it requires out-of-band authorization
#resource "aws_sns_topic_subscription" "bucket_writes_sub" {
#    topic_arn = "${aws_sns_topic.bucket_writes.arn}"
#    protocol = "email"
#    endpoint = "..."
#}


output "tf_state_bucket_arn" {
    value = "${aws_s3_bucket.tf_state-bucket.arn}"
}
output "tf_state_bucket_id" {
    value = "${aws_s3_bucket.tf_state-bucket.id}"
}
