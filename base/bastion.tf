# Allow SSH access to bastion host
resource "aws_security_group" "bastion_external-sg" {
    name = "bastion_external-sg"
    description = "Allow SSH to bastion host from all"
    ingress {
        from_port = 22
        to_port = 22
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
        Name = "bastion_external-sg"
    }
}

# Allow all access from bastion host(s) to all resources
resource "aws_security_group" "bastion_internal-sg" {
    name = "bastion_internal-sg"
    description = "Allow all access from bastion host"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${aws_security_group.bastion_external-sg.id}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${aws_security_group.bastion_external-sg.id}"]
    }
    tags {
        Name = "bastion_internal-sg"
    }
}

# Launch config for bastion ASG
resource "aws_launch_configuration" "bastion-lc" {
    name_prefix = "bastion-lc-"
    instance_type = "t2.micro"
    image_id = "${lookup(var.centos7_amis, var.region)}"
    key_name = "klibby@mozilla.com"
    security_groups = ["${aws_security_group.bastion_external-sg.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.ec2_read_keys-profile.arn}"
    user_data = "${file("files/bastion-userdata.sh")}"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "bastion-asg" {
    name = "bastion-asg"
    availability_zones = ["us-west-2a"]
    max_size = 2
    min_size = 1
    desired_capacity = 1
    launch_configuration = "${aws_launch_configuration.bastion-lc.name}"
    lifecycle {
        create_before_destroy = true
    }
    tag {
        key = "Name"
        value = "bastion"
        propagate_at_launch = true
    }
    tag {
        key = "Type"
        value = "autoscale instance"
        propagate_at_launch = true
    }
}
