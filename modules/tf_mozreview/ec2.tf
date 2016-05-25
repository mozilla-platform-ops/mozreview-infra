# EC2 resources

# Create web head ec2 instances and evenly distribute them across the web subnets/azs
resource "aws_instance" "web_ec2_instance" {
    ami = "${var.web_ami_id}"
    count = "${var.web_instances_per_subnet * length(split(",", var.web_subnets))}"
    subnet_id = "${element(aws_subnet.web_subnet.*.id, count.index % length(split(",", var.web_subnets)))}"
    instance_type = "${var.web_instance_type}"
    user_data = "${file("${path.module}/files/web_userdata.sh")}"

    iam_instance_profile = "${var.web_instance_profile}"

# TODO: better tags
    tags {
        Name = "${var.web_instance_name}-${count.index}"
    }
}
