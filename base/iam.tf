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

# Add manage_own_creds group
resource "aws_iam_group" "manage_own_creds-group" {
    name = "manage_own_creds"
}

# NB: when adding a new ec2_assume-like role, also add it to s3_read_pubkeys

# Allow EC2 to assume role to read SSH pub key bucket (see files/s3_read_pubkeys.json.tmpl)
resource "aws_iam_role" "ec2_assume-role" {
    name = "ec2_assume_role"
    assume_role_policy = "${file("files/ec2_assume.json")}"
}

# Allow bastion hosts to AssumeRole
resource "aws_iam_role" "ec2_manage_eip-role" {
    name = "ec2_manage_eip"
    assume_role_policy = "${file("files/ec2_assume.json")}"
}

# Allow bastion hosts to manage their Elastic IP
resource "aws_iam_role_policy" "ec2_manage_eip-policy" {
    name = "ec2_manage_eip-policy"
    role = "${aws_iam_role.ec2_manage_eip-role.id}"
    policy = "${file("files/ec2_manage_EIP.json")}"
}

# NB: AWS does not support multiple roles per instance profile; instead, apply
# multiple policies to a single roll. cf https://github.com/hashicorp/terraform/issues/3851

# Create instance profile for EC2 instances to assume role
resource "aws_iam_instance_profile" "ec2_read_keys-profile" {
    name = "ec2_read_keys"
    role = "${aws_iam_role.ec2_assume-role.name}"
}

# Create instance profile for bastion hosts to manage EIP
resource "aws_iam_instance_profile" "ec2_manage_eip-profile" {
    name = "ec2_manage_eip"
    role = "${aws_iam_role.ec2_manage_eip-role.name}"
}

# Create a policy that requires multifactor authentication
resource "aws_iam_policy" "require_mfa-policy" {
    name = "require_mfa-policy"
    description = "Require use of Multifactor Authentication"
    policy = "${file("files/RequireMFA.json")}"
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

