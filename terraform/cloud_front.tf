resource "aws_cloudfront_distribution" "distribution" {
  aliases = [data.terraform_remote_state.my-aws-settings.outputs.my_domain_zone.name]

  // api gateway 設定
  //  origin {
  //    domain_name = replace(aws_api_gateway_deployment..invoke_url, "/^https?://([^/]*).*/", "$1")
  //    origin_id   = "api-gw"
  //
  //    custom_origin_config {
  //      http_port              = 80
  //      https_port             = 443
  //      origin_protocol_policy = "https-only"
  //      origin_ssl_protocols   = ["TLSv1.2"]
  //    }
  //  }
  //
  //  ordered_cache_behavior {
  //    path_pattern           = "/api/*"
  //    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  //    cached_methods         = ["GET", "HEAD"]
  //    target_origin_id       = "api-gw"
  //    viewer_protocol_policy = "redirect-to-https"
  //    min_ttl                = 0
  //    default_ttl            = 3600  # 1 hour
  //    max_ttl                = 86400 # 24 hours
  //
  //    forwarded_values {
  //      query_string = true
  //      headers      = ["x-api-key"]
  //      cookies {
  //        forward = "all"
  //      }
  //    }
  //  }

  // S3 設定
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/index.html"
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "my site cloudfront distribution"
  http_version    = "http2"
  //web_acl_id      = aws_wafv2_web_acl.main.arn

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600  # 1 hour
    max_ttl                = 86400 # 24 hours

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    //    function_association {
    //      event_type   = "viewer-request"
    //      function_arn = aws_cloudfront_function.function.arn
    //    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}

//resource "aws_cloudfront_function" "function" {
//  name    = "my-site-cloud-front-function"
//  runtime = "cloudfront-js-1.0"
//  comment = "my-site-cloud-front-function"
//  publish = true
//  code    = file("dist/index.js")
//}
