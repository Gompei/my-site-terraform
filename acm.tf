resource "aws_acm_certificate" "certificate" {
  domain_name               = var.root_domain
  subject_alternative_names = ["*.${var.root_domain}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "acm_certificate" {
  for_each = {
    for domain in aws_acm_certificate.certificate.domain_validation_options : domain.domain_name => {
      name   = domain.resource_record_name
      record = domain.resource_record_value
      type   = domain.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = var.host_zone_id
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_certificate : record.fqdn]
}
