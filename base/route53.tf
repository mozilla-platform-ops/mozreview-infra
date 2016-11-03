# This is a hosted zone delegated from mozilla.org
resource "aws_route53_zone" "autoland-hz" {
    name = "autoland.mozilla.org"
}

# This is a hosted zone delegated from mozops.net
# which is managed under the moz-devservices aws account
resource "aws_route53_zone" "mozops_mozreview-hz" {
    name = "mozreview.mozops.net"
}
