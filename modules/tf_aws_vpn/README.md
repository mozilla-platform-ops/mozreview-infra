Terraform AWS VPN module
========================

A Terraform module to create a single VPN in AWS.

**NB**: AWS will provide a **random** /30 IPv4 subnet in RFC-1918 space for the ipsec tunnel.
If you have multiple tunnels (to other VPCs) there is **no** guarantee that they won't use a /30
already in use (by you). If you find that you have an address conflict, you will need to destroy
the VPN connection and re-create it (e.g. `terraform destroy -target=aws_vpn_connection`)

Input Variables
---------------
- `name` - Name of the VPC (will be used in tags)
- `vpc_id` - ID of the VPC to attach the vpn
- `main_route_table_id` - ID of the VPCs main route table. VPN route will be added
- `vpn_bgp_asn` -  BPG ASN of the customer gateway for a dynamically routed VPN connection.
- `vpn_ip_address` - IP address of the customer gateway's external interface
- `vpn_dest_cidr_block` - Internal CIDR block to advertise over the VPN to the VPC


Modules Usage
-------------

```js
module "vpc" {
  source = "github.com/dividehex/tf_aws_vpn"

  name = "my-vpc"
  vpc_id = "vpc-68c3600c"

  main_route_table_id = "rtb-faef8a9e"

  vpn_bgp_asn = "65000"
  vpn_ip_address = "1.2.3.4"
  vpn_dest_cidr_block = "192.168.1.0/24"
}
```


Outputs
-------
- `Customer gateway` - Customer gateway ID
- `VPN gateway` - VPN gateway ID
- `VPN gateway config` - XML configuration for your hardware VPN


Authors
=======

Simplified and modified by Jake Watkins
Original Credits go to [Kendall Libby](https://github.com/klibby), based on [tf_aws_vpc](https://github.com/terraform-community-modules/tf_aws_vpc) by [Casey Ransom](https://github.com/cransom) and [Paul Hinze](https://github.com/phinze)

License
=======
Mozilla Public License, version 2.0. See LICENSE for full details.

