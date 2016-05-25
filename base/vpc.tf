/*
This file defines the global VPC configuration including VPNs
*/

# Define Primary VPC network
resource "aws_vpc" "primary_vpc" {
    # This is a NetOps sanctioned cidr block - see bug 1272453
    cidr_block = "10.191.4.0/24"

    tags {
        Name = "Primary VPC"
    }
}

# This security group should only be used for debugging
resource "aws_security_group" "allow_all-sg" {
    name = "allow_all-sg"
    description = "Allow all inbound and outbound traffic"
    vpc_id = "${aws_vpc.primary_vpc.id}"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "Allow all"
    }
}

# Add primary igw route
resource "aws_route" "route_all_rt_rule" {
    route_table_id = "${aws_vpc.primary_vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.primary_igw.id}"
}

# Establish a primary internet gateway
resource "aws_internet_gateway" "primary_igw" {
    vpc_id = "${aws_vpc.primary_vpc.id}"

    tags {
        Name = "Primary Internet Gateway"
    }
}

# Setup VPN connection SCL3 <--> VPC
module "vpn" {
  source = "../modules/tf_aws_vpn"

  name = "mozreview"
  vpc_id = "${aws_vpc.primary_vpc.id}"

  main_route_table_id = "${aws_vpc.primary_vpc.main_route_table_id}"

  vpn_bgp_asn = "65022"
  vpn_ip_address = "63.245.214.100"
  vpn_dest_cidr_block = "10.0.0.0/8"
}

module "bastion_vpc" {
    source = "../modules/tf_aws_vpc"

    name = "bastion-vpc"
    cidr = "${var.bastion_cidr}"
    public_subnets = "${var.bastion_cidr}"
    azs_public = "us-west-2a"
}
