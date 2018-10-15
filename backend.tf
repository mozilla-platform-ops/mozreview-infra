# As of 0.9.0, remote state is configured through the new backend system
# See https://www.terraform.io/docs/backends/legacy-0-8.html

terraform {
  backend "s3" {
    # run init.sh to initialize your env and configure the backend
    bucket = "moz-mozreview-state"
    region = "us-west-2"
  }
}
