# Outputs

# Elastic IP for bastion host
output "webhead_ips" {
    value = "${join(",", aws_instance.web_ec2_instance.*.private_ip)}"
}
