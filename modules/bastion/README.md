AWS bastion host module
=======================

A terraform module to create a bastion host autoscaling group and EIP within a VPC in AWS.


Module Input Variables
----------------------

- `name` - Resource name, used in tags (default: bastion)
- `ami` - Amazon machine image ID
- `instance_type` - EC2 instance type (default: t2.micro)
- `instance_profile` - IAM instance profile (see below)
- `vpc_id` - VPC ID in which to place the ASG
- `public_subnet_ids` - Public subnet ID(s) in which to launch ASG
- `allowd_cidr_blocks` - CIDR block of address which should be allowed to connect (default: 0.0.0.0/0)
- `s3_key_bucket` - S3 bucket containing SSH pub keys (see below)
- `addl_user_data` - Additional user data script to run (default: none)

Usage
-----

```js
module "bastion" {
    source = "path/to/bastion"

    name = "bastion"
    ami = "${lookup(var.centos7_amis, var.region)}"
    instance_profile = "arn:aws:iam::ACCOUNT_ID:instance-profile/bastion"
    vpc_id = "vpc-xxxxxxxx"
    public_subnet_ids = "subnet-xxxxxx"
    s3_key_bucket = "my-ssh-pubkey-bucket"
}
```

The user-data script creates and runs two secondary scripts when the instance is provisioned.
Both are placed in $HOME/bin, where $HOME is dependant on the OS (e.g. /home/centos on CentOS).

- `update_ssh_keys.sh` - Reads SSH pub keys from a bucket and adds them to ~/.ssh/authorized_keys
- `associate_eip.sh` - Reads an EIP tag on the instance and associates it with the EIP

The IAM instance profile should allow EC2 instances to read tags and access the bucket.
(TODO: add examples)

Outputs
-------

- `bastion_ip` - foo
- `external_sg_id` - foo

Authors
=======

Created by [Kendall Libby](https://github.com/klibby)

License
=======
Mozilla Public License, version 2.0. See LICENSE for full details.
