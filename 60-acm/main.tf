#create https certificate from amazon vendor
resource "aws_acm_crtificate" "devopspract" {
  domain_name       = "*.{var.route53_zone_name}"
  validation_method = "DNS"
  tags = merge(local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
  })
  lifecycle {
    create_before_destroy = true
  }

}

#create route 53 record for the above created certificate as we need to create TXT records
resource "aws_route53_record" "devopspract" {
  #take required info from the certificate
  for_each = {
    for dvo in aws_acm_crtificate.devopspract.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource.record_value
      type   = dvo.resource.record_types
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

#click validate button
#validate the records created in aws_route53 for the certificate
resource "aws_acm_certificate_validation" "devopspract" {
  certificate_arn         = aws_acm_crtificate.devopspract.arn
  validation_record_fqdns = [for record in aws_aws_route53_record.devopspract : record.fqdn]
}


