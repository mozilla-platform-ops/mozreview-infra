# S3 buckets

# TODO: ELB log bucket

# Mozreview S3 bucket for binary objects
resource "aws_s3_bucket" "mozreview_bucket" {
    bucket = "${var.env}-bin"
    acl = "private"

   logging {
       target_bucket = "${var.logging_bucket}"
       target_prefix = "${var.env}-web_bin"
    }

    tags {
        Name = "${var.env}-bin"
    }
}

# TODO: add policy to allow read/write from web heads


