# Setup autoland vpc

resource "aws_vpc" "autoland_vpc" {

    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags {
        Name = "autoland-${var.env}-vpc"
    }
}

# Setup internet gateway for vpc
    resource "aws_internet_gateway" "autoland_igw" {
    vpc_id = "${aws_vpc.autoland_vpc.id}"

    tags {
        Name = "autoland-${var.env}-igw"
    }
}

# Setup route table for public subnets
resource "aws_route_table" "autoland_public-rt" {
    vpc_id = "${aws_vpc.autoland_vpc.id}"
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
        Name = "autoland-${var.env}-subnet"
    }

  map_public_ip_on_launch = true
}

 resource "aws_route_table_association" "autoland" {
   count = "${length(compact(split(",", var.subnets)))}"
   subnet_id = "${element(aws_subnet.autoland_subnet.*.id, count.index)}"
route_table_id = "${aws_route_table.autoland_public-rt.id}"
}
