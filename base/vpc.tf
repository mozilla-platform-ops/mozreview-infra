/*
This file defines the shared VPC configurations including VPNs
*/


module "bastion_vpc" {
    source = "../modules/tf_aws_vpc"

    name = "bastion-vpc"
    cidr = "${var.bastion_cidr}"
    public_subnets = "${var.bastion_cidr}"
    azs_public = "us-west-2a"
}

