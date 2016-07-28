
output "rds_address" {
    value = "${aws_db_instance.autoland-rds.address}"
}
output "eip_address" {
    value = "${aws_eip.autoland_web-eip.public_ip}"
}

