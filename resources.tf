# This file contains shared global resources

# Configure remote state for mozreview_base
# This allows use of base outputs such as primary_vpc id
data "terraform_remote_state" "mozreview_base" {
    backend = "s3"
    config {
        encrypt = true
        acl = "private"
        bucket = "${var.tf_state_bucket}"
        region = "${var.region}"
        key = "base/${var.tf_state_file}"
    }
}

# outputs can be accessed via
# ${terraform_remote_state.mozreview_base.output.output_name}

