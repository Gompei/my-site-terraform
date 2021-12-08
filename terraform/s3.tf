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

// 画像用バケット
resource "aws_s3_bucket" "s3_bucket_image" {
  bucket = "my-site-image-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "bucket_image_policy" {
  bucket = aws_s3_bucket.s3_bucket_image.id
  policy = data.aws_iam_policy_document.iam_policy_2.json
}

// TODO:リファクタリング予定
// TODO:命名規則決める
// TODO: CloudFront噛ませる必要があるか検討
data "aws_iam_policy_document" "iam_policy_2" {
  statement {
    sid    = "Allow CloudFront"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      ]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket_image.arn}/*"]
  }
  statement {
    sid     = "Allow S3 upload"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    // TODO: おかしい気がする
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = ["${aws_s3_bucket.s3_bucket_image.arn}/*"]
    condition {
      test = "ArnEquals"
      values = [
        aws_s3_bucket.s3_bucket.arn
      ]
      variable = "aws:SourceArn"
    }
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
