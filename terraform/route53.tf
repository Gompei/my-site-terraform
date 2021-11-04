resource "aws_route53_record" "alb" {
  zone_id = var.host_zone_id
  name    = var.root_domain
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
  }
}
