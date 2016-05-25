# Setup mozreview vpc
resource "aws_vpc" "mozreview_vpc" {

    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true

#TODO: tags

}

# Setup internet gateway for vpc
resource "aws_internet_gateway" "mozreview_igw" {
    vpc_id = "${aws_vpc.mozreview_vpc.id}"
#TODO: tags
}

# Setup route table for public subnets
resource "aws_route_table" "mozreview_public-rt" {
    vpc_id = "${aws_vpc.mozreview_vpc.id}"
}

# Setup route table for private subnets
resource "aws_route_table" "mozreview_private-rt" {
    vpc_id = "${aws_vpc.mozreview_vpc.id}"
#TODO: tags
}

# Add default route to internet bound route table
resource "aws_route" "mozreview_public_igw-rtr" {
    route_table_id = "${aws_route_table.mozreview_public-rt.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mozreview_igw.id}"
#TODO: tags
}

# Setup private subnets for webheads
resource "aws_subnet" "web_subnet" {
  vpc_id = "${aws_vpc.mozreview_vpc.id}"
  cidr_block = "${element(split(",", var.web_subnets), count.index)}"
  availability_zone = "${element(split(",", var.web_azs), count.index)}"
  count = "${length(compact(split(",", var.web_subnets)))}"
#  tags { Name = "${var.name}-private" }
#TODO: tags
}

# Setup public subnets for elb
resource "aws_subnet" "elb_subnet" {
  vpc_id = "${aws_vpc.mozreview_vpc.id}"
  cidr_block = "${element(split(",", var.elb_subnets), count.index)}"
  availability_zone = "${element(split(",", var.elb_azs), count.index)}"
  count = "${length(compact(split(",", var.elb_subnets)))}"
#  tags { Name = "${var.name}-public" }
#TODO: tags

  map_public_ip_on_launch = true
}

# Setup private subnets for rds
resource "aws_subnet" "rds_subnet" {
  vpc_id = "${aws_vpc.mozreview_vpc.id}"
  cidr_block = "${element(split(",", var.rds_subnets), count.index)}"
  availability_zone = "${element(split(",", var.rds_azs), count.index)}"
  count = "${length(compact(split(",", var.rds_subnets)))}"
#  tags { Name = "${var.name}-public" }
#TODO: tags
}

resource "aws_route_table_association" "web" {
  count = "${length(compact(split(",", var.web_subnets)))}"
  subnet_id = "${element(aws_subnet.web_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.mozreview_private-rt.id}"
}

resource "aws_route_table_association" "elb" {
  count = "${length(compact(split(",", var.elb_subnets)))}"
  subnet_id = "${element(aws_subnet.elb_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.mozreview_public-rt.id}"
}

