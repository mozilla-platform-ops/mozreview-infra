# Create bucket for remote state
resource "aws_s3_bucket" "tf_state-bucket" {
    bucket = "${var.tf_state_bucket}"
    acl = "private"
    #policy = ""
    versioning {
        enabled = true
    }
    logging {
        target_bucket = "${module.cloudtrail.bucket_id}"
        target_prefix = "s3/${var.tf_state_bucket}/"
    }
    tags {
        Name = "terraform state bucket"
        Env = "shared"
    }
}

# Enable notifications for tf_state bucket
resource "aws_s3_bucket_notification" "tf_state_bucket-notify" {
    bucket = "${aws_s3_bucket.tf_state-bucket.id}"
    topic {
        topic_arn = "${aws_sns_topic.tf_state_bucket-topic.arn}"
        events = [
            "s3:ObjectCreated:*",
            "s3:ObjectRemoved:*"
        ]
    }
}

# Render policy to allow EC2 assumed role to read SSH pubkey bucket
resource "template_file" "s3_read_pubkeys-template" {
    template = "${file("files/s3_read_pubkeys.json.tmpl")}"
    vars {
        account_id = "${var.account_id}"
        key_bucket = "${var.ssh_pub_key_bucket}"
        ec2_assume_role = "${aws_iam_role.ec2_assume-role.name}"
        ec2_manage_eip_role = "${aws_iam_role.ec2_manage_eip-role.name}"
    }
}

# Create bucket for SSH public keys
resource "aws_s3_bucket" "ssh_pubkey-bucket" {
    bucket = "${var.ssh_pub_key_bucket}"
    acl = "private"
    policy = "${template_file.s3_read_pubkeys-template.rendered}"
    logging {
        target_bucket = "${module.cloudtrail.bucket_id}"
        target_prefix = "s3/${var.ssh_pub_key_bucket}/"
    }
    tags {
        Name = "SSH public keys"
    }
}

# Manage SSH public keys
resource "aws_s3_bucket_object" "ssh_pubkeys" {
    bucket = "${var.ssh_pub_key_bucket}"
    count = "${length(split(",", var.ssh_key_names))}"
    key = "${element(split(",", var.ssh_key_names), count.index)}"
    content = "${file("files/pubkeys/${element(split(",", var.ssh_key_names), count.index)}")}"
    depends_on = ["aws_s3_bucket.ssh_pubkey-bucket"]
}

# Render policy to allow EC2 assumed role to read base bucket
resource "template_file" "s3_base_bucket-template" {
    template = "${file("files/s3_base_bucket.json.tmpl")}"
    vars {
        account_id = "${var.account_id}"
        key_bucket = "${var.base_bucket}"
        ec2_assume_role = "${aws_iam_role.ec2_assume-role.name}"
        ec2_manage_eip_role = "${aws_iam_role.ec2_manage_eip-role.name}"
    }
}

# Create base bucket for SSH pub keys, user-data scripts, etc
resource "aws_s3_bucket" "s3_base-bucket" {
    bucket = "${var.base_bucket}"
    acl = "private"
    policy = "${template_file.s3_base_bucket-template.rendered}"
    logging {
        target_bucket = "${module.cloudtrail.bucket_id}"
        target_prefix = "s3/${var.base_bucket}/"
    }
    tags {
        Name = "S3 base bucket"
        Env = "shared"
    }
}

# Manage SSH public keys
resource "aws_s3_bucket_object" "ssh_pub_keys" {
    bucket = "${var.base_bucket}"
    count = "${length(split(",", var.ssh_key_names))}"
    key = "pubkeys/${element(split(",", var.ssh_key_names), count.index)}"
    content = "${file("files/pubkeys/${element(split(",", var.ssh_key_names), count.index)}")}"
    depends_on = ["aws_s3_bucket.s3_base-bucket"]
}

# Manage user-data scripts
resource "aws_s3_bucket_object" "user-data" {
    bucket = "${var.base_bucket}"
    count = "${length(split(",", var.user_data_scripts))}"
    key = "user-data/${element(split(",", var.user_data_scripts), count.index)}"
    content = "${file("files/user-data/${element(split(",", var.user_data_scripts), count.index)}")}"
    depends_on = ["aws_s3_bucket.s3_base-bucket"]
}
# user-data template scripts need extra effort
resource "template_file" "s3_userdata_pubkeys-template" {
    template = "${file("files/user-data/ssh-pubkeys.tmpl")}"
    vars {
        base_bucket = "${var.base_bucket}"
        pubkey_bucket_prefix = "${var.pubkey_bucket_prefix}"
    }
}
resource "aws_s3_bucket_object" "pubkeys-user-data" {
    bucket = "${var.base_bucket}"
    key = "user-data/ssh-pubkeys"
    content = "${template_file.s3_userdata_pubkeys-template.rendered}"
    depends_on = ["aws_s3_bucket.s3_base-bucket", "template_file.s3_userdata_pubkeys-template"]
}
