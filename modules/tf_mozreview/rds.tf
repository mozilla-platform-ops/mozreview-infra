# RDS instance

# Setup db_subnet_group
resource "aws_db_subnet_group" "mozreview_dbsg" {
    name = "${var.env}-db_subnet_group"
    description = "Mozreview DB Subnet Group"
    subnet_ids = ["${aws_subnet.rds_subnet.*.id}"]
    tags {
        Name = "${var.env}-mozreview-db-subnet-grp"
    }
}

resource "aws_security_group" "mozreview_db-sg" {
    name = "${var.env}_db-sg"
    description = "Provides RDS access to web instances"
    vpc_id = "${aws_vpc.mozreview_vpc.id}"
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        security_groups = ["${aws_security_group.mozreview_web-sg.id}"]
    }
    tags {
        Name = "${var.env}-mozreview-db-sg"
    }
}

resource "aws_db_instance" "mozreview-rds" {
    identifier = "${var.env}-mozreview-rds"
    storage_type = "gp2"
    allocated_storage = 500
    engine = "mysql"
    engine_version = "5.6.23"
    instance_class = "${var.rds_instance_class}"
    username = "mozreview_admin"
    password = "change_this_after_deployment"
    backup_retention_period = 1
    backup_window = "07:00-07:30"
    maintenance_window = "Sun:08:00-Sun:08:30"
    multi_az = "True"
    port = "3306"
    publicly_accessible = "False"
    auto_minor_version_upgrade = "False"
    db_subnet_group_name = "${aws_db_subnet_group.mozreview_dbsg.name}"
    vpc_security_group_ids = ["${aws_security_group.mozreview_db-sg.id}"]
# TODO: add monitoring arn and enable monitoring
#    monitoring_role_arn = "arn:aws:iam::699292812394:role/rds-monitoring-role"
#    monitoring_interval = 60
    tags {
        Name = "${var.env}-mozreview-rds"
    }
}

