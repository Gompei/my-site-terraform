resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.host_zone_id
  name    = var.root_domain
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "api_gateway_alias" {
  zone_id = var.host_zone_id
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
  }
}
