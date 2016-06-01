# Elasitic Load Balancer

resource "aws_security_group" "mozreview_elb-sg" {
    name = "${var.env}-mozreview-elb-sg"
    description = "Elb instance security group"
    vpc_id = "${aws_vpc.mozreview_vpc.id}"
    ingress {
        from_port = 80
        to_port = 80
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
        Name = "${var.env}-mozreview-elb-sg"
    }
}

# Setup ELB for mozreview webheads
# Create a new load balancer
resource "aws_elb" "mozreview_web_elb" {
    name = "${var.env}-elb"
    subnets = ["${aws_subnet.elb_subnet.*.id}"]
    security_groups = ["${aws_security_group.mozreview_elb-sg.id}"]

# TODO: Uploud SSL cert and flip to https
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    instances = ["${aws_instance.web_ec2_instance.*.id}"]
    cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400
/*
    # Logging
    access_logs {
        bucket = "${var.logging_bucket}"
        bucket_prefix = "elb/web-${var.env}"
        interval = 60
    }
*/
# TODO: Health Checks
    tags {
        Name = "${var.env}-mozreview-elb"
    }
}

