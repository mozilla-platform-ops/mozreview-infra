variable "vpn_bgp_asn" {
    description = "BPG Autonomous System Number (ASN) of the customer gateway for a dynamically routed VPN connection."
}
variable "vpn_ip_address" {
    description = "Internet-routable IP address of the customer gateway's external interface."
}
variable "vpn_dest_cidr_block" {
    description = "Internal network IP range to advertise over the VPN connection to the VPC."
}
variable "vpc_id" {
    description = "The VPC id the VPN will be attached to"
}
variable "main_route_table_id" {
    description = "The main route table used by the VPN"
}
variable "name" {
    description = "The name of the VPC."
}
