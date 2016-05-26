resource "template_file" "user_data" {
    template = "${file("${path.module}/files/user_data.tmpl")}"
    vars {
        s3_bucket = "${var.base_bucket}"
        addl_user_data = "${var.user_data_scripts}"
    }
}

resource "aws_instance" "hg" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    subnet_id = "${var.subnet_id}"
    ebs_optimized = true
    disable_api_termination = "${var.disable_termination}"
    associate_public_ip_address = true
    vpc_security_group_ids = ["${split(",", var.vpc_sg_ids)}"]
    user_data = "${template_file.user_data.rendered}"
    iam_instance_profile = "${var.instance_profile}"
    tags {
        Name = "${var.name}"
        EIP = "${aws_eip.eip.public_ip}"
        MountPoint = "${var.mount_point}"
    }
}

resource "aws_ebs_volume" "vol" {
    availability_zone = "${var.availability_zone}"
    size = "${var.volume_size}"
    type = "${var.volume_type}"
    tags {
        Name = "${var.name}-vol"
        MountPoint = "${var.mount_point}"
    }
}

resource "aws_volume_attachment" "attach" {
    device_name = "${var.device_name}"
    volume_id = "${aws_ebs_volume.vol.id}"
    instance_id = "${aws_instance.hg.id}"
}

resource "aws_elb" "elb" {
    name = "hg-elb"
    instances = ["${aws_instance.hg.id}"]
    security_groups = [""]
    subnets = ["${var.subnet_id}"]
    
    access_logs {
        bucket = "${var.logging_bucket}"
        interval = 60
    }
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    #listener {
    #    instance_port = 443
    #    instance_protocol = "https"
    #    lb_port = 443
    #    lb_protocol = "https"
    #    #ssl_certificate_id = "arn:..."
    #}
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:80/"
        interval = 5
    }
    tags {
        Name = "hg-elb"
    }
}
