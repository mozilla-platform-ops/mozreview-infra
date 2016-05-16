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

