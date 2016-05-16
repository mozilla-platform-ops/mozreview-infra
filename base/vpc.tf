/*
This file defines the global VPC configuration including VPNs
*/

# Create EIP for bastion host (to be associated later)
resource "aws_eip" "bastion-eip" {
    vpc = true
    lifecycle {
        prevent_destroy = true
    }
}

# Define Primary VPC network
resource "aws_vpc" "primary_vpc" {
    # cidr_block will change once determined by netops
    cidr_block = "10.0.0.0/16"

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

# SSH and icmp inbound
resource "aws_security_group" "ssh_only-sg" {
    name = "ssh_only-sg"
    description = "Allow inbound ssh only"
    vpc_id = "${aws_vpc.primary_vpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "SSH and ICMP only"
    }
}

# Establish a primary route table
resource "aws_route_table" "primary_route_table-rt" {
    vpc_id = "${aws_vpc.primary_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.primary_igw.id}"
    }
    tags {
        Name = "Primary Route Table"
    }
}

# Set primary_route_table-rt as Main route table
resource "aws_main_route_table_association" "assosciate_primary_rt" {
    vpc_id = "${aws_vpc.primary_vpc.id}"
    route_table_id = "${aws_route_table.primary_route_table-rt.id}"
}

# Establish a primary internet gateway
resource "aws_internet_gateway" "primary_igw" {
    vpc_id = "${aws_vpc.primary_vpc.id}"

    tags {
        Name = "Primary Internet Gateway"
    }
}


# Establish a vpn gateway on the primary VPC
#resource "aws_vpn_gateway" "primary_vpn_gateway" {
#    vpc_id = "${aws_vpc.primary_vpc.id}"
#}

# Setup a customer gateway dedicated to SCL3
#resource "aws_customer_gateway" "customer_gateway_SCL3" {
#    bgp_asn = 60000
#    ip_address = "10.0.0.1"
#    type = "ipsec.1"
#}

# Connect the SCL3 customer gateway to the Primary VPC
#resource "aws_vpn_connection" "primary_vpn_connection" {
#    vpn_gateway_id = "${aws_vpn_gateway.primary_vpn_gateway.id}"
#    customer_gateway_id = "${aws_customer_gateway.customer_gateway_SCL3.id}"
#    type = "ipsec.1"
#    static_routes_only = false
#
#    tags {
#        Name = "PRIMARY <-> SCL3 VPN"
#    }
#}


