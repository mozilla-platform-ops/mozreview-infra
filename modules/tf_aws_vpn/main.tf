resource "aws_vpn_gateway" "vpc-vgw" {
    vpc_id = "${var.vpc_id}"
    tags {
        Name = "${var.name}-vgw"
    }
}
resource "aws_route" "vgw-route" {
    route_table_id = "${var.main_route_table_id}"
    destination_cidr_block = "${var.vpn_dest_cidr_block}"
    gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
}

resource "aws_customer_gateway" "vpc-cgw" {
    bgp_asn = "${var.vpn_bgp_asn}"
    ip_address = "${var.vpn_ip_address}"
    type = "ipsec.1"
    tags {
        Name = "${var.name}-cgw"
    }
}

resource "aws_vpn_connection" "vpc-vpn" {
    vpn_gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
    customer_gateway_id = "${aws_customer_gateway.vpc-cgw.id}"
    type = "ipsec.1"
    static_routes_only = false
    tags {
        Name = "${var.name}-vpn"
    }
}
