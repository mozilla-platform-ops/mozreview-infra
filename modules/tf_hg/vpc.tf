resource "aws_eip" "eip" {
    vpc = true
}

# ideally this would also include the VPC, subnet(s), and security_group(s), but
# because of the VPN requirement thos are all handled in mozreview_base
