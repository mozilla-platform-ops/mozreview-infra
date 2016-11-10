module "bastion" {
    source = "../modules/bastion"

    name = "bastion"
    ami = "${lookup(var.centos7_amis, var.region)}"
    instance_type = "t2.medium"
    instance_profile = "${aws_iam_instance_profile.ec2_manage_eip-profile.arn}"
    vpc_id = "${module.bastion_vpc.vpc_id}"
    public_subnet_ids = "${module.bastion_vpc.public_subnets}"
    s3_key_bucket = "${var.base_bucket}"
    addl_user_data = "ssh-pubkeys,associate-eip,set_sysctl"
}

# route53 A record for bastion eip
resource "aws_route53_record" "bastion-eip-1_usw2_mozreview_mozops_net" {
    zone_id = "${data.terraform_remote_state.mozreview_base.mozops_route53_zone_id}"
    name = "bastion-eip-1.usw2.mozreview.mozops.net"
    type = "A"
    ttl = "300"
    records = ["${module.bastion.bastion_ip}"]
}

# route53 CNAME pointing at bastion eip
resource "aws_route53_record" "bastion_usw2_mozreview_mozops_net" {
    zone_id = "${data.terraform_remote_state.mozreview_base.mozops_route53_zone_id}"
    name = "bastion.usw2.mozreview.mozops.net"
    type = "CNAME"
    ttl = "300"
    records = ["${aws_route53_record.bastion-eip-1_usw2_mozreview_mozops_net.fqdn}"]
}
