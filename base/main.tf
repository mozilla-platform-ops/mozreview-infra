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

# Configure password policy
resource "aws_iam_account_password_policy" "strict" {
    minimum_password_length = 16
    require_lowercase_characters = true
    require_numbers = true
    require_uppercase_characters = true
    require_symbols = true
    allow_users_to_change_password = true
}

# Add manage_own_creds group
resource "aws_iam_group" "manage_own_creds-group" {
    name = "manage_own_creds"
}

# Create a policy that allows user to manage their own credentials
resource "aws_iam_policy" "manage_own_credentialss-policy" {
    name = "manage_own_credentials-policy"
    description = "Allow users to manage their own credentials"
    policy = "${file("files/manage_own_credentials.json")}"
}

# Attach manage_own_creds policy to group
resource "aws_iam_policy_attachment" "manage_own_credentials-attach" {
    name = "manage_own_credentials-attach"
    groups = ["${aws_iam_group.manage_own_creds-group.name}"]
    policy_arn = "${aws_iam_policy.manage_own_credentialss-policy.arn}"
}

# Add admin group
resource "aws_iam_group" "admin-group" {
    name = "administrators"
}

# Create a policy that requires multifactor authentication
resource "aws_iam_policy" "require_mfa-policy" {
    name = "require_mfa-policy"
    description = "Require use of Multifactor Authentication"
    policy = "${file("files/RequireMFA.json")}"
}

# Attach MFA policy to admin group
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

# Create a policy to allow S3 bucket notifications to SNS
variable "tf_sns_topic_name" {
    description = "Hack to work around GH-4157"
    default = "tf_state_notifications"
}
resource "template_file" "bucket_sns-policy" {
    template = "${file("files/bucket_sns.json.tmpl")}"
    vars {
        region = "${var.region}"
        account_id = "${var.account_id}"
        topic_name = "${var.tf_sns_topic_name}"
        bucket_name = "${var.tf_state_bucket}"
    }
}

# Create an SNS topic for tf_state-bucket notifications
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

# Enable notifications for tf_state bucket
resource "aws_s3_bucket_notification" "tf_state_bucket-notify" {
    bucket = "${aws_s3_bucket.tf_state-bucket.id}"
    topic {
        topic_arn = "${aws_sns_topic.tf_state_bucket-topic.arn}"
        events = [
            "s3:ObjectCreated:*",
            "s3:ObjectRemoved:*"
        ]
    }
}

# Allow EC2 to assume role for further actions
resource "aws_iam_role" "ec2_assume-role" {
    name = "ec2_assume_role"
    assume_role_policy = "${file("files/ec2_assume.json")}"
}

# Create instance profile for EC2 instances to assume role
resource "aws_iam_instance_profile" "ec2_read_keys-profile" {
    name = "ec2_read_keys"
    roles = ["${aws_iam_role.ec2_assume-role.name}"]
}

# fubar: I think this is redundant with the s3 bucket policy and ec2 instance profile
## Render policy to allow EC2 instances to read SSH pubkeys
#resource "template_file" "ec2_read_keys-template" {
#    template = "${file("files/ec2_read_keys.json.tmpl")}"
#    vars {
#        key_bucket = "${var.ssh_pub_key_bucket}"
#    }
#}
#
## Add role policy to allow EC2 instances to read they key bucket
#resource "aws_iam_role_policy" "ec2_read_keys-policy" {
#    name = "ec2_read_keys-policy"
#    role = "${aws_iam_role.ec2_assume-role.id}"
#    policy = "${template_file.ec2_read_keys-template.rendered}"
#}

# Render policy to allow EC2 assumed role to read SSH pubkey bucket
resource "template_file" "s3_read_pubkeys-template" {
    template = "${file("files/s3_read_pubkeys.json.tmpl")}"
    vars {
        account_id = "${var.account_id}"
        key_bucket = "${var.ssh_pub_key_bucket}"
        ec2_role = "${aws_iam_role.ec2_assume-role.name}"
    }
}

# Create bucket for SSH public keys
resource "aws_s3_bucket" "ssh_pubkey-bucket" {
    bucket = "${var.ssh_pub_key_bucket}"
    acl = "private"
    policy = "${template_file.s3_read_pubkeys-template.rendered}"
    logging {
        target_bucket = "${module.cloudtrail.bucket_id}"
        target_prefix = "s3/${var.ssh_pub_key_bucket}/"
    }
    tags {
        Name = "SSH public keys"
    }
}

