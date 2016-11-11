# EC2 resources

data "template_file" "user_data" {
    template = "${file("${path.module}/files/user_data.tmpl")}"
    vars {
        s3_bucket = "${var.user_data_bucket}"
        addl_user_data = "${var.addl_user_data}"
    }
}

resource "aws_security_group" "autoland_web-sg" {
    name = "autoland_${var.env}_web-sg"
    description = "Web instance security group"
    vpc_id = "${aws_vpc.autoland_vpc.id}"
    ingress {
        from_port = 8
        to_port = "-1"
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # Allow all from bastion sg
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${var.allow_bastion_sg}"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = ["${aws_security_group.autoland_alb-sg.id}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "${var.env}-autoland-sg"
    }
}

resource "aws_eip" "autoland_web-eip" {
    vpc = true
    #lifecycle {
    #    prevent_destroy = true
    #}
}

# Create web head ec2 instances and evenly distribute them across the web subnets/azs
resource "aws_instance" "web_ec2_instance" {
    ami = "${var.ami_id}"
    count = 1
    subnet_id = "${aws_subnet.autoland_subnet.0.id}"
    instance_type = "${var.instance_type}"
    user_data = "${data.template_file.user_data.rendered}"
    vpc_security_group_ids = ["${aws_security_group.autoland_web-sg.id}"]
    iam_instance_profile = "${var.instance_profile}"

    associate_public_ip_address = true
    root_block_device {
        volume_type = "gp2"
        volume_size = 32
        delete_on_termination = true
    }

    ebs_block_device {
        device_name = "/dev/sdb"
        volume_type = "gp2"
        volume_size = 32
        delete_on_termination = true
    }

    tags {
        Name = "${var.env}-autoland-${count.index}"
        EIP = "${aws_eip.autoland_web-eip.public_ip}"
    }
}

resource "aws_alb_target_group_attachment" "autoland_tg_attachment" {
    target_group_arn = "${aws_alb_target_group.autoland-alb-tg.arn}"
    target_id = "${aws_instance.web_ec2_instance.id}"
    port = 80
}
