# Elasticache

resource "aws_elasticache_subnet_group" "mozreview-elc-subnet-group" {
    name = "${var.env}-elc-subnet-group"
    description = "Mozreview Elasticache Subnet Group"
    subnet_ids = ["${aws_subnet.elc_subnet.*.id}"]
}

resource "aws_security_group" "mozreview-elc-sg" {
    name = "${var.env}-elc-sg"
    description = "${var.env} Elasticache security group"
    vpc_id = "${aws_vpc.mozreview_vpc.id}"

    ingress {
        from_port = 11211
        to_port = 11211
        protocol = "tcp"
        security_groups = ["${aws_security_group.mozreview_web-sg.id}"]
    }

    tags {
        Name = "${var.env}-mozreview-sg"
    }
}

resource "aws_elasticache_parameter_group" "mozreview-elc-pg" {
    name = "memcache-params"
    family = "memcached1.4"
    description = "Mozreview memcache cluster param group"

}

resource "aws_elasticache_cluster" "mozreview-elc" {
    cluster_id = "${var.env}-elc"
    engine = "memcached"
    engine_version = "1.4.24"
    node_type = "${var.memcached_instance_type}"
    port = 11211
    num_cache_nodes = "${var.num_memcached_nodes}"
    az_mode = "cross-az"
    subnet_group_name = "${aws_elasticache_subnet_group.mozreview-elc-subnet-group.name}"
    availability_zones = ["${split(",", var.elc_azs)}"]
    maintenance_window = "Sun:08:00-Sun:09:00"
    security_group_ids = ["${aws_security_group.mozreview-elc-sg.id}"]
    parameter_group_name = "${aws_elasticache_parameter_group.mozreview-elc-pg.name}"

    tags {
        Name = "${var.env}-mozreview-elc"
    }
}
