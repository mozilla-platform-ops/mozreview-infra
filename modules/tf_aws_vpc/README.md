vpc terraform module
===========

A terraform module to provide a VPC in AWS.


Module Input Variables
----------------------

- `name` - vpc name
- `cidr` - vpc cidr
- `public_subnets` - comma separated list of public subnet cidrs
- `private_subnets` - - comma separated list of private subnet cidrs
- `azs_private` - comma separated lists of AZs in which to distribute private subnets
- `azs_public` - comma separated lists of AZs in which to distribute public subnets
- `enable_dns_hostnames` - should be true if you want to use private DNS within the VPC
- `enable_dns_support` - should be true if you want to use private DNS within the VPC

Each subnet list should be equal in length to its respective availablity zone list.

Usage
-----

```js
module "vpc" {
  source = "github.com/dividehex/tf_aws_vpc"

  name = "my-vpc"

  cidr = "10.0.0.0/16"
  private_subnets = "10.0.1.0/24,10.0.2.0/24,10.0.3.0/24"
  public_subnets  = "10.0.101.0/24,10.0.103.0/24"

  azs_private     = "us-west-2a,us-west-2b,us-west-2c"
  azs_public      = "us-west-2a,us-west-2c"
}
```

Outputs
=======

 - `vpc_id` - does what it says on the tin
 - `private_subnets` - comma separated list of private subnet ids
 - `public_subnets` - comma separated list of public subnet ids
 - `public_route_table_id` - public route table id string
 - `private_route_table_id` - private route table id string

Authors
=======

Modified by [Jake Watkins](https://github.com/dividehex)

Originally created and maintained by [Casey Ransom](https://github.com/cransom)
Hijacked by [Paul Hinze](https://github.com/phinze)

License
=======

Apache 2 Licensed. See LICENSE for full details.
