output "hg_eip" {
    value = "${aws_eip.eip.public_ip}"
}
output "hg_elb_id" {
    value = "${aws_elb.elb.id}"
}
output "hg_elb_name" {
    value = "${aws_elb.elb.name}"
}
output "hg_elb_dns" {
    value = "${aws_elb.elb.dns_name}"
}
