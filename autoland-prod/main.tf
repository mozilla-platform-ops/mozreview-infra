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
    subnets = "192.168.0.0/28"
    azs = "${lookup(var.availablity_zones, var.region)}"

    rds_subnets = "192.168.0.16/28,192.168.0.32/28,192.168.0.48/28"
    rds_azs = "${lookup(var.availablity_zones, var.region)}"
    rds_instance_class = "db.t2.micro"

    instance_profile = "${terraform_remote_state.mozreview_base.output.eip_instance_profile_name}"

    allow_bastion_sg = "${terraform_remote_state.mozreview_base.output.allow_bastion_sg}"

    peer_vpc_id = "${terraform_remote_state.mozreview_base.output.bastion_vpc}"
    peer_route_table_id = "${terraform_remote_state.mozreview_base.output.bastion_rtb}"
    peer_cidr_block = "${var.bastion_cidr}"
    peer_account_id = "${var.account_id}"

    user_data_bucket = "${var.base_bucket}"
    addl_user_data = "ssh-pubkeys,associate-eip,set_sysctl"
}

output "autoland_rds_address" {
    value = "${module.autoland.rds_address}"
}

output "autoland_eip_address" {
    value = "${module.autoland.eip_address}"
}

