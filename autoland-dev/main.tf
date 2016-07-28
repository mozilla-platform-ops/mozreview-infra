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
    subnets = "172.29.1.0/24"
    azs = "${lookup(var.availablity_zones, var.region)}"

    rds_subnets = "172.29.2.0/24,172.29.3.0/24,172.29.4.0/24"
    rds_azs = "${lookup(var.availablity_zones, var.region)}"
    rds_instance_class = "db.t2.micro"

    instance_profile = "${terraform_remote_state.mozreview_base.output.eip_instance_profile_name}"

    allow_bastion_sg = "${terraform_remote_state.mozreview_base.output.allow_bastion_sg}"

    peer_vpc_id = "${terraform_remote_state.mozreview_base.output.bastion_vpc}"
    peer_route_table_id = "${terraform_remote_state.mozreview_base.output.bastion_rtb}"
    peer_cidr_block = "${var.bastion_cidr}"
    peer_account_id = "${var.account_id}"

    user_data_bucket = "${var.base_bucket}"
    addl_user_data = "ssh-pubkeys,associate-eip"
}

output "autoland_rds_address" {
    value = "${module.autoland.rds_address}"
}

output "autoland_eip_address" {
    value = "${module.autoland.eip_address}"
}

