resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.terraform_remote_state.my-aws-settings.outputs.my_domain_zone.zone_id
  name    = data.terraform_remote_state.my-aws-settings.outputs.my_domain_zone.name
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
  }
}
