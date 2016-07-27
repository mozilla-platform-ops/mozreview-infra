# RDS

# Setup subnet group
resource "aws_db_subnet_group" "autoland_dbsg" {
    name = "${var.env}-db_subnet_group"
    description = "Autoland DB Subnet Group"
    subnet_ids = ["${aws_subnet.autoland_rds_subnet.*.id}"]
    tags {
        Name = "${var.env}-autoland-db-subnet-grp"
    }
}

resource "aws_security_group" "autoland_db-sg" {
    name = "${var.env}_db-sg"
    description = "Provides RDS access to autoland instances"
    vpc_id = "${aws_vpc.autoland_vpc.id}"
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.autoland_web-sg.id}"]
    }
    tags {
        Name = "${var.env}-autoland-db-sg"
    }
}

resource "aws_db_instance" "autoland-rds" {
    identifier = "${var.env}-autoland-rds"
    storage_type = "gp2"
    allocated_storage = 500
    engine = "postgres"
    engine_version = "9.5.2"
    instance_class = "${var.rds_instance_class}"
    username = "autoland_admin"
    password = "change_this_after_deployment"
    backup_retention_period = 1
    backup_window = "07:00-07:30"
    maintenance_window = "Sun:08:00-Sun:08:30"
    multi_az = "True"
    port = "5432"
    publicly_accessible = "False"
    auto_minor_version_upgrade = "False"
    db_subnet_group_name = "${aws_db_subnet_group.autoland_dbsg.name}"
    vpc_security_group_ids = ["${aws_security_group.autoland_db-sg.id}"]
# TODO: add monitoring arn and enable monitoring
#    monitoring_role_arn = "arn:aws:iam::699292812394:role/rds-monitoring-role"
#    monitoring_interval = 60
    tags {
        Name = "${var.env}-autoland-rds"
    }
}

