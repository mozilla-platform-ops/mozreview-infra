Terraform hg module
========================

A Terraform module to create an instance with attached EBS volume and EIP for mercurial.

(Because of the VPN requirement, most VPC-related resources are created outside of this
module and passed. Ideally they should be contained within the module.)

Input Variables
---------------
- `name` - Stack name (used in tags)
- `ami` - EC2 instance AMI to run
- `instance_type` - EC2 instance type (default: t2.micro)
- `instance_profile` - IAM instance profile
- `disable_termination` - Boolean to disable API instance termination (default: false)
- `subnet_id` - VPC subnet ID to launch into
- `vpc_sg_ids` - VPC security group IDs to associate with the instance
- `availability_zone` - AZ to deploy into
- `base_bucket` - Base S3 bucket containing SSH pub keys and user-data scripts
- `user_data_scripts` - User-data scripts to run from S3
- `volume_size` - EBs volume size, in gigabytes
- `volume_type` - EBS volume type (default: gp2)
- `device_name` - Linux device name (default: /dev/xvdg)
- `mount_point` - Where to mount the EBS volume

Modules Usage
-------------

```js
module "hg" {
    source = "../modules/hg"

    name = "hg_test"
    ami = "${lookup(var.centos6_amis, var.region)}"
    instance_type = "m4.large"
    instance_profile = "${terraform_remote_state.mozreview_base.output.eip_instance_profile_name}"
    subnet_id = "${aws_subnet.hg-subnet.id}"
    vpc_sg_ids = "${concat(aws_security_group.bastion_to_vpn-sg.id, ",", aws_security_group.hg_public-sg.id)}"
    availability_zone = "us-west-2a"
    base_bucket = "${var.base_bucket}"
    user_data_scripts = "ssh-pubkeys,associate-eip,attach-vol"
    volume_size = 40
    mount_point = "/repo"
}
```

Below are examples of the VPC pieces that are NOT included in the module and thus should
be created elsewhere (e.g. mozreview-base):

```js
resource "aws_subnet" "hg-subnet" {
    vpc_id = "${terraform_remote_state.mozreview_base.output.hg_vpc}"
    cidr_block = "${terraform_remote_state.mozreview_base.output.hg_vpc_cidr}"
    availability_zone = "us-west-2a"
    tags {
        Name = "hg-subnet"
    }
}

resource "aws_security_group" "hg_public-sg" {
    name = "hg_public-sg"
    vpc_id = "${terraform_remote_state.mozreview_base.output.hg_vpc}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "hg_public-sg"
    }
}

resource "aws_security_group" "bastion_to_vpn-sg" {
    name = "bastion_to_vpn-sg"
    vpc_id = "${terraform_remote_state.mozreview_base.output.hg_vpc}"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${terraform_remote_state.mozreview_base.output.allow_bastion_sg}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${terraform_remote_state.mozreview_base.output.allow_bastion_sg}"]
    }
}
```

Outputs
-------
- `hg_eip` - Elastic IP address of the hg host

Authors
=======

[Kendall Libby](https://github.com/klibby)

License
=======
Mozilla Public License, version 2.0. See LICENSE for full details.

