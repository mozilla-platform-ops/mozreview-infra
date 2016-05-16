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
