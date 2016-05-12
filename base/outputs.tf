# This file contains all base outputs which can be consumed
# by other terraform environments.  Such as vpcs and security groups

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

