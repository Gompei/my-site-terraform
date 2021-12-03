resource "aws_s3_bucket" "s3_bucket" {
  bucket = data.terraform_remote_state.my-aws-settings.outputs.my_domain_zone.name
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.iam_policy.json
}

data "aws_iam_policy_document" "iam_policy" {
  statement {
    sid    = "Allow CloudFront"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]
  }
}

// lambdaソースアップロード
resource "aws_s3_bucket_object" "lambda" {
  bucket = data.terraform_remote_state.my-aws-settings.outputs.lambda_bucket_ap-northeast-1.bucket
  key    = "my-site/lambda.zip"
  source = "lambda.zip"
  etag   = filemd5("lambda.zip")
  lifecycle {
    ignore_changes = [
      etag,
      metadata
    ]
  }
}
