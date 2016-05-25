# This file contains all base outputs which can be consumed
# by other terraform environments.  Such as vpcs and security groups

# EC2 instance profile to read key bucket
output "pubkey_instance_profile_name" {
    value = "${aws_iam_instance_profile.ec2_read_keys-profile.name}"
}
output "pubkey_instance_profile_arn" {
    value = "${aws_iam_instance_profile.ec2_read_keys-profile.arn}"
}
# EC2 instance profile to manage EIP
output "eip_instance_profile_name" {
    value = "${aws_iam_instance_profile.ec2_manage_eip-profile.name}"
}
output "eip_instance_profile_arn" {
    value = "${aws_iam_instance_profile.ec2_manage_eip-profile.arn}"
}

# VPCs
output "primary_vpc" {
    value = "${aws_vpc.primary_vpc.id}"
}

# Security Groups
output "allow_all-sg" {
    value = "${aws_security_group.allow_all-sg.id}"
}

output "ssh_only-sg" {
    value = "${aws_security_group.ssh_only-sg.id}"
}

output "allow_from_bastion-sg" {
    value = "${aws_security_group.bastion_internal-sg.id}"
}

# Elastic IP for bastion host
output "bastion_eip" {
    value = "${aws_eip.bastion-eip.public_ip}"
}
