output "Customer gateway" {
    value = "${aws_customer_gateway.vpc-cgw.id}"
}

output "VPN gateway" {
    value = "${aws_vpn_gateway.vpc-vgw.id}"
}

output "VPN gateway config" {
    value = "${aws_vpn_connection.vpc-vpn.customer_gateway_configuration}"
}
