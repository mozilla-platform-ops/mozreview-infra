# Setup autoland vpc

resource "aws_vpc" "autoland_vpc" {

    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags {
        Name = "${var.env}-autoland-vpc"
    }
}

module "vpc_bastion_peer" {
    source = "../tf_vpc_peer"

     name = "${var.env}-bastion_peer"
     requester_vpc_id = "${aws_vpc.autoland_vpc.id}"
     requester_route_table_id = "${aws_route_table.autoland_public-rt.id}"
     requester_cidr_block = "${var.vpc_cidr}"
     peer_vpc_id = "${var.peer_vpc_id}"
     peer_route_table_id = "${var.peer_route_table_id}"
     peer_cidr_block = "${var.peer_cidr_block}"
     peer_account_id = "${var.peer_account_id}"
}

# Setup internet gateway for vpc
resource "aws_internet_gateway" "autoland_igw" {
    vpc_id = "${aws_vpc.autoland_vpc.id}"

    tags {
        Name = "${var.env}-autoland-igw"
    }
}

# Setup route table for public subnets
resource "aws_route_table" "autoland_public-rt" {
    vpc_id = "${aws_vpc.autoland_vpc.id}"

    tags {
        Name = "${var.env}-autoland-public-rt"
    }
}

# Setup route table for private subnets
resource "aws_route_table" "autoland_private-rt" {
    vpc_id = "${aws_vpc.autoland_vpc.id}"

    tags {
        Name = "${var.env}-autoland-private-rt"
    }
}

# Add default route to internet bound route table
resource "aws_route" "autoland_public_igw-rtr" {
    route_table_id = "${aws_route_table.autoland_public-rt.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.autoland_igw.id}"
}

# Setup public subnets for autoland
resource "aws_subnet" "autoland_subnet" {
    vpc_id = "${aws_vpc.autoland_vpc.id}"
    cidr_block = "${element(split(",", var.subnets), count.index)}"
    availability_zone = "${element(split(",", var.azs), count.index)}"
    count = "${length(compact(split(",", var.subnets)))}"
    tags {
        Name = "${var.env}-autoland-subnet-${count.index}"
    }
}

resource "aws_subnet" "autoland_rds_subnet" {
    vpc_id = "${aws_vpc.autoland_vpc.id}"
    cidr_block = "${element(split(",", var.rds_subnets), count.index)}"
    availability_zone = "${element(split(",", var.rds_azs), count.index)}"
    count = "${length(compact(split(",", var.rds_subnets)))}"
    tags {
        Name = "${var.env}-autoland-rds-subnet-${count.index}"
    }
}

resource "aws_route_table_association" "autoland-public" {
    count = "${length(compact(split(",", var.subnets)))}"
    subnet_id = "${element(aws_subnet.autoland_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.autoland_public-rt.id}"
}

resource "aws_route_table_association" "autoland-private" {
    count = "${length(compact(split(",", var.rds_subnets)))}"
    subnet_id = "${element(aws_subnet.autoland_rds_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.autoland_private-rt.id}"
}
