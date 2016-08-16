# S3 buckets

# Mozreview S3 bucket for binary objects
resource "aws_s3_bucket" "mozreview_bucket" {
    bucket = "${var.env}-mozreveiw-bin"
    acl = "private"

   logging {
       target_bucket = "${var.logging_bucket}"
       target_prefix = "s3/${var.env}-mozreview-bin/"
    }

    tags {
        Name = "${var.env}-mozreview-bin"
    }
}

# TODO: add policy to allow read/write from web heads

/*
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
*/
