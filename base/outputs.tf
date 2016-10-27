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
output "hg_vpc" {
    value = "${aws_vpc.primary_vpc.id}"
}
output "hg_vpc_cidr" {
    value = "${aws_vpc.primary_vpc.cidr_block}"
}
output "bastion_vpc" {
    value = "${module.bastion_vpc.vpc_id}"
}
output "bastion_rtb" {
    value = "${module.bastion_vpc.public_route_table_id}"
}

# Security Groups
output "allow_bastion_sg" {
    value = "${module.bastion.external_sg_id}"
}

# Elastic IP for bastion host
output "bastion_eip" {
    value = "${module.bastion.bastion_ip}"
}

# Autoland hosted zone ID
output "autoland_route53_zone_id" {
    value = "${aws_route53_zone.autoland-hz.zone_id}"
}
