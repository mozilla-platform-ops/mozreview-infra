variable "account_id" {
    description = "AWS Account ID"
}

variable "bucket_name" {
    description = "Name of S3 bucket in which to store Cloudtrail logs"
}

resource "template_file" "logging_bucket_policy" {
    template = "${file("${path.module}/cloudtrail_bucket.json.tmpl")}"
    vars {
        account_id = "${var.account_id}"
        bucket_name = "${var.bucket_name}"
    }
}

resource "aws_s3_bucket" "logging_bucket" {
    bucket = "${var.bucket_name}"
    acl = "private"
    policy = "${template_file.logging_bucket_policy.rendered}"
    tags {
        Name = "cloudtrail bucket"
    }
}

resource "aws_cloudtrail" "cloudtrail" {
    name = "cloudtrail"
    s3_bucket_name = "${aws_s3_bucket.logging_bucket.id}"
    include_global_service_events = true
    is_multi_region_trail = true
    tags {
        Name = "local cloudtrail"
    }
}

output "bucket_id" {
    value = "${aws_s3_bucket.logging_bucket.id}"
}

output "bucket_arn" {
    value = "${aws_s3_bucket.logging_bucket.arn}"
}

output "cloudtrail_id" {
    value = "${aws_cloudtrail.cloudtrail.id}"
}

output "cloudtrail_arn" {
    value = "${aws_cloudtrail.cloudtrail.arn}"
}
