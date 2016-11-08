
output "rds_address" {
    value = "${aws_db_instance.autoland-rds.address}"
}

output "eip_address" {
    value = "${aws_eip.autoland_web-eip.public_ip}"
}

output "alb_dns_name" {
    value = "${aws_alb.autoland_alb.dns_name}"
}

output "alb_zone_id" {
    value = "${aws_alb.autoland_alb.zone_id}"
}
