provider "aws" {
    profile = "${var.profile}"
    region  = "${var.region}"
}

module "autoland" {
    source = "../modules/tf_autoland"

    env = "${var.env}"
    vpc_cidr = "172.29.0.0/16"

    instance_type = "t2.medium"
    ami_id = "ami-075b9b67"
    subnets = "172.29.1.0/24,172.29.5.0/24,172.29.6.0/24"
    azs = "${lookup(var.availablity_zones, var.region)}"

    rds_subnets = "172.29.2.0/24,172.29.3.0/24,172.29.4.0/24"
    rds_azs = "${lookup(var.availablity_zones, var.region)}"
    rds_instance_class = "db.t2.micro"

    instance_profile = "${data.terraform_remote_state.mozreview_base.eip_instance_profile_name}"

    allow_bastion_sg = "${data.terraform_remote_state.mozreview_base.allow_bastion_sg}"

    peer_vpc_id = "${data.terraform_remote_state.mozreview_base.bastion_vpc}"
    peer_route_table_id = "${data.terraform_remote_state.mozreview_base.bastion_rtb}"
    peer_cidr_block = "${var.bastion_cidr}"
    peer_account_id = "${var.account_id}"

    user_data_bucket = "${var.base_bucket}"
    addl_user_data = "ssh-pubkeys,associate-eip"
    ssl_cert_arn = "arn:aws:acm:us-west-2:154007893214:certificate/5a364d17-a006-44e2-b7e8-bd2d73920cb1"

    logging_bucket = "${var.cloudtrail_bucket}"
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

