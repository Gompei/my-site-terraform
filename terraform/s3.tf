# Front
resource "aws_s3_bucket" "bucket" {
  bucket = var.root_domain
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
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
    actions = [
      "s3:GetObject"
    ]

    resources = ["${aws_s3_bucket.bucket.arn}/*"]
  }
}

# lambdaソースアップロード
resource "aws_s3_bucket_object" "lambda" {
  bucket = "gompei-lambda-management-bucket-us-east-1"
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

