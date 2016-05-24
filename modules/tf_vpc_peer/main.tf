#-------------------------------------------------------------------------
# This module creates a VPC peering connection and routes between two VPCs
#-------------------------------------------------------------------------

variable "name"                     { }
variable "requester_vpc_id"         { }
variable "requester_route_table_id" { }
variable "requester_cidr_block"     { }
variable "peer_vpc_id"              { }
variable "peer_route_table_id"      { }
variable "peer_cidr_block"          { }
variable "peer_account_id"          { }
variable "auto_accept"              { default = true }

output "vpx_id" {
    value = "${aws_vpc_peering_connection.vpx.id}"
}
output "accept_status" {
    value = "${aws_vpc_peering_connection.vpx.accept_status}"
}

resource "aws_vpc_peering_connection" "vpx" {
    vpc_id = "${var.requester_vpc_id}"
    peer_vpc_id = "${var.peer_vpc_id}"
    peer_owner_id = "${var.peer_account_id}"
    auto_accept = "${var.auto_accept}"
    tags {
        Name = "${var.name}-pcx"
    }
}

resource "aws_route" "req_to_peer-route" {
    route_table_id = "${var.requester_route_table_id}"
    destination_cidr_block = "${var.peer_cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpx.id}"
}

resource "aws_route" "peer_to_req-route" {
    route_table_id = "${var.peer_route_table_id}"
    destination_cidr_block = "${var.requester_cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpx.id}"
}
