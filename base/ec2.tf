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
