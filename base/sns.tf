# Create a policy to allow S3 bucket notifications to SNS
variable "tf_sns_topic_name" {
    description = "Hack to work around GH-4157"
    default = "tf_state_notifications"
}
resource "template_file" "bucket_sns-policy" {
    template = "${file("files/bucket_sns.json.tmpl")}"
    vars {
        region = "${var.region}"
        account_id = "${var.account_id}"
        topic_name = "${var.tf_sns_topic_name}"
        bucket_name = "${var.tf_state_bucket}"
    }
}

# Create an SNS topic for tf_state-bucket notifications
resource "aws_sns_topic" "tf_state_bucket-topic" {
    name = "${var.tf_sns_topic_name}"
    display_name = "tf-state"
    policy = "${template_file.bucket_sns-policy.rendered}"
}

# email protocol not supported, as it requires out-of-band authorization
#resource "aws_sns_topic_subscription" "bucket_writes_sub" {
#    topic_arn = "${aws_sns_topic.bucket_writes.arn}"
#    protocol = "email"
#    endpoint = "..."
#}

