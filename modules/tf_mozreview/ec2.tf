# EC2 resources
/*
resource "aws_security_group" "mozreview_web-sg" {
    name = "${var.env}_web-sg"
    description = "Web instance security group"
    vpc_id = "${aws_vpc.mozreview_vpc.id}"
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
        security_groups = ["${var.allow_from_bastion-sg}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "${var.env}_db-sg"
    }
}
*/

# Create web head ec2 instances and evenly distribute them across the web subnets/azs
resource "aws_instance" "web_ec2_instance" {
    ami = "${var.web_ami_id}"
    count = "${var.web_instances_per_subnet * length(split(",", var.web_subnets))}"
    subnet_id = "${element(aws_subnet.web_subnet.*.id, count.index % length(split(",", var.web_subnets)))}"
    instance_type = "${var.web_instance_type}"
    user_data = "${file("${path.module}/files/web_userdata.sh")}"
#    vpc_security_group_ids = ["${aws_security_group.mozreview_web-sg.name}"]
    iam_instance_profile = "${var.web_instance_profile}"

# TODO: better tags
    tags {
        Name = "${var.web_instance_name}-${count.index}"
    }
}
