# EC2 resources

resource "template_file" "user_data" {
    template = "${file("${path.module}/files/user_data.tmpl")}"
    vars {
        s3_bucket = "${var.user_data_bucket}"
        addl_user_data = "${var.addl_user_data}"
    }
    lifecycle {
        create_before_destroy = true
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
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "autoland_${var.env}_web-sg"
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
    count = "${length(split(",", var.subnets))}"
    subnet_id = "${element(aws_subnet.autoland_subnet.*.id, count.index % length(split(",", var.subnets)))}"
    instance_type = "${var.instance_type}"
    user_data = "${template_file.user_data.rendered}"
    vpc_security_group_ids = ["${aws_security_group.autoland_web-sg.id}"]
    iam_instance_profile = "${var.instance_profile}"

    associate_public_ip_address = true
    root_block_device {
        volume_type = "gp2"
        volume_size = 10
        delete_on_termination = true
    }

    tags {
        Name = "autoland-${var.env}-web-${count.index}"
        EIP = "${aws_eip.autoland_web-eip.public_ip}"
    }
}
