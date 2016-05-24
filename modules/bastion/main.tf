#---------------------------------------------------------------
# This module creates all resources necessary for a Bastion host
#---------------------------------------------------------------

variable "name"                { default = "bastion" }
variable "ami"                 { }
variable "instance_type"       { default = "t2.micro" }
variable "instance_profile"    { }
variable "vpc_id"              { }
variable "public_subnet_ids"   { }
variable "allowed_cidr_blocks" { default = "0.0.0.0/0" }
variable "s3_key_bucket"       { }
variable "addl_user_data"      { default = "" }

output "bastion_ip" {
    value = "${aws_eip.bastion-eip.public_dns}"
}

output "external_sg_id" {
    value = "${aws_security_group.bastion_external-sg.id}"
}

# Create EIP for bastion host (to be associated later)
resource "aws_eip" "bastion-eip" {
    vpc = true
    lifecycle {
        prevent_destroy = true
    }
}

# Allow SSH access to bastion host
resource "aws_security_group" "bastion_external-sg" {
    name = "${var.name}_external-sg"
    description = "Allow SSH to bastion host from all"
    vpc_id = "${var.vpc_id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${split(",", var.allowed_cidr_blocks)}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "${var.name}_external-sg"
    }
}

resource "template_file" "user_data" {
    template = "${file("${path.module}/user_data.tmpl")}"
    vars {
        s3_key_bucket = "${var.s3_key_bucket}"
        addl_user_data = "${var.addl_user_data}"
    }
    lifecycle {
        create_before_destroy = true
    }
}

# Launch config for bastion ASG
resource "aws_launch_configuration" "bastion-lc" {
    name_prefix = "${var.name}-lc-"
    instance_type = "${var.instance_type}"
    image_id = "${var.ami}"
    security_groups = ["${aws_security_group.bastion_external-sg.id}"]
    iam_instance_profile = "${var.instance_profile}"
    user_data = "${template_file.user_data.rendered}"
    key_name = "klibby@mozilla.com"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "bastion-asg" {
    depends_on = ["${aws_launch_configuration.bastion-lc.id}"]
    name = "${var.name}-asg"
    vpc_zone_identifier = ["${split(",", var.public_subnet_ids)}"]
    max_size = 1
    min_size = 1
    desired_capacity = 1
    wait_for_capacity_timeout = 0
    health_check_grace_period = "60"
    health_check_type = "EC2"
    force_delete = false
    launch_configuration = "${aws_launch_configuration.bastion-lc.name}"
    lifecycle {
        create_before_destroy = true
    }
    tag {
        key = "Name"
        value = "${var.name}"
        propagate_at_launch = true
    }
    tag {
        key = "EIP"
        value = "${aws_eip.bastion-eip.public_ip}"
        propagate_at_launch = true
    }
}
