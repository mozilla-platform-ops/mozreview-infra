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
        ec2_bastion_role = "${aws_iam_role.ec2_bastion-role.name}"
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
        ec2_bastion_role = "${aws_iam_role.ec2_bastion-role.name}"
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
