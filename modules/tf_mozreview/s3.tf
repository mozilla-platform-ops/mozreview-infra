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


