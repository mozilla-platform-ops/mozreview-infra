provider "aws" {
    profile = "${var.profile}"
    region  = "${var.region}"
}

module "autoland" {
    source = "../modules/tf_autoland"

    env = "${var.env}"
    vpc_cidr = "192.168.0.0/24"

    instance_type = "t2.medium"
    ami_id = "ami-075b9b67"
    subnets = "192.168.0.0/28,192.168.0.64/28,192.168.0.80/28"
    azs = "${lookup(var.availablity_zones, var.region)}"

    rds_subnets = "192.168.0.16/28,192.168.0.32/28,192.168.0.48/28"
    rds_azs = "${lookup(var.availablity_zones, var.region)}"
    rds_instance_class = "db.t2.micro"

    instance_profile = "${data.terraform_remote_state.mozreview_base.eip_instance_profile_name}"

    allow_bastion_sg = "${data.terraform_remote_state.mozreview_base.allow_bastion_sg}"

    peer_vpc_id = "${data.terraform_remote_state.mozreview_base.bastion_vpc}"
    peer_route_table_id = "${data.terraform_remote_state.mozreview_base.bastion_rtb}"
    peer_cidr_block = "${var.bastion_cidr}"
    peer_account_id = "${var.account_id}"

    user_data_bucket = "${var.base_bucket}"
    addl_user_data = "ssh-pubkeys,associate-eip,set_sysctl"
    ssl_cert_arn = "arn:aws:acm:us-west-2:154007893214:certificate/5a364d17-a006-44e2-b7e8-bd2d73920cb1"

    logging_bucket = "${var.cloudtrail_bucket}"
}

# route53 A (Alias) record for autoland ALB
resource "aws_route53_record" "autoland-alb-1_usw2_mozreview_mozops_net" {
    zone_id = "${data.terraform_remote_state.mozreview_base.mozops_route53_zone_id}"
    name = "autoland-alb-1.usw2.mozreview.mozops.net"
    type = "A"

    alias {
      name = "${module.autoland.alb_dns_name}"
      zone_id = "${module.autoland.alb_zone_id}"
      evaluate_target_health = true
    }
}

# route53 A record for autoland EIP
resource "aws_route53_record" "autoland-eip-1_usw2_mozreview_mozops_net" {
    zone_id = "${data.terraform_remote_state.mozreview_base.mozops_route53_zone_id}"
    name = "autoland-eip-1.usw2.mozreview.mozops.net"
    type = "A"
    ttl = "300"
    records = ["${module.autoland.eip_address}"]
}

# route53 CNAME record for autoland RDS
resource "aws_route53_record" "autoland-rds-1_usw2_mozreview_mozops_net" {
    zone_id = "${data.terraform_remote_state.mozreview_base.mozops_route53_zone_id}"
    name = "autoland-rds-1.usw2.mozreview.mozops.net"
    type = "CNAME"
    ttl = "300"
    records = ["${module.autoland.rds_address}"]
}

output "autoland_rds_address" {
    value = "${module.autoland.rds_address}"
}

output "autoland_eip_address" {
    value = "${module.autoland.eip_address}"
}

output "autoland_alb_dns_name" {
    value = "${module.autoland.alb_dns_name}"
}

output "autoland_mozops_fqdns" {
    value = ["${aws_route53_record.autoland-alb-1_usw2_mozreview_mozops_net.fqdn}",
             "${aws_route53_record.autoland-eip-1_usw2_mozreview_mozops_net.fqdn}",
             "${aws_route53_record.autoland-rds-1_usw2_mozreview_mozops_net.fqdn}"]
}

