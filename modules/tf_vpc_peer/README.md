AWS VPC peering module
======================

A terraform module to create a VPC peering connection between two VPCs, with routes between
them.

Module Input Variables
----------------------

- `name` - bar
- `requester_vpc_id` - Requester's VPC ID
- `requester_route_table_id` - Route table ID of the requester's VPC
- `requester_cidr_block` - CIDR block of the requester's VPC
- `peer_vpc_id` - Peer's VPC ID
- `peer_route_table_id` - Route table ID of the peer's VPC
- `peer_cidr_block` - CIDR block of the peer's VPC
- `peer_account_id` - AWS account id of the peer
- `auto_accept` - Whether to auto accept if in same account (default: true)

Usage
-----

```js
module "" {
    source = "path/to/module"

    name = "vpc1_to_vpc2"
    requester_vpc_id = "vpc-xxxxxxxx"
    requester_route_table_id = "rtb-xxxxxxxx"
    requester_cidr_block = "192.168.1.0/24"
    peer_vpc_id = "vpc-yyyyyyyy"
    peer_route_table_id = "rtb-yyyyyyyy"
    peer_cidr_block = "192.168.2.0/24"
    peer_account_id = "1234567889012"
}
```

Outputs
-------

- `vpx_id` - VPC peering connection ID
- `accept_status` - Peering request accept status

Authors
=======

Created by [Kendall Libby](https://github.com/klibby)

License
=======
Mozilla Public License, version 2.0. See LICENSE for full details.

