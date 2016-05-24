# Elasitic Load Balancer

# Setup ELB for mozreview webheads
# Create a new load balancer
resource "aws_elb" "mozreview_web_elb" {
    name = "${var.env}-elb"

    subnets = ["${aws_subnet.elb_subnet.*.id}"]


# TODO: Uploud SSL cert and flip to https
    listener {
        instance_port = 8000
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    instances = ["${aws_instance.web_ec2_instance.*.id}"]
    cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400

    # Logging
    access_logs {
        bucket = "${var.logging_bucket}"
        bucket_prefix = "elb/web-${var.env}"
        interval = 60
    }

# TODO: Health Checks
    tags {
        Name = "${var.env}-elb"
    }
}

