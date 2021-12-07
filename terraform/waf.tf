resource "aws_wafv2_web_acl" "main" {
  provider    = aws.us-east-1
  name        = "my-site-waf"
  description = "my-site-waf"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "my-site-waf-metric"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "my-site-waf-metric"
      sampled_requests_enabled   = false
    }
  }
}
