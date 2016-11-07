resource "aws_security_group" "autoland_alb-sg" {
    name = "${var.env}-autoland-alb-sg"
    description = "ALB instance security group"
    vpc_id = "${aws_vpc.autoland_vpc.id}"
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
        Name = "${var.env}-autoland-alb-sg"
    }
}

resource "aws_alb" "autoland_alb" {
    name            = "${var.env}-autoland-alb"
    internal        = false
    security_groups = ["${aws_security_group.autoland_alb-sg.id}"]
    subnets         = ["${aws_subnet.autoland_subnet.*.id}"]

    enable_deletion_protection = true

    access_logs {
        bucket = "${var.logging_bucket}"
    }
}

resource "aws_alb_target_group" "autoland-alb-tg" {
    name     = "autoland-alb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = "${aws_vpc.autoland_vpc.id}"
}

resource "aws_alb_listener" "autoland-alb-https-listener" {
    load_balancer_arn = "${aws_alb.autoland_alb.arn}"
    port = "443"
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2015-05"
    certificate_arn = "${var.ssl_cert_arn}"

    default_action {
        target_group_arn = "${aws_alb_target_group.autoland-alb-tg.arn}"
        type = "forward"
    }
}
