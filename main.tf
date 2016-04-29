provider "aws" {
    profile = "${var.profile}"
    region  = "${var.region}"
}

# Enable Cloudtrail logging to S3 bucket local to account
module "cloudtrail" {
    source = "./cloudtrail"
    account_id = "${var.account_id}"
    bucket_name = "${var.bucket}"
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
