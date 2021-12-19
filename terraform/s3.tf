########################################################
# S3 Bucket
########################################################
resource "aws_s3_bucket" "s3_bucket_hosting" {
  depends_on = [data.aws_iam_policy_document.iam_policy]
  bucket     = data.terraform_remote_state.my-aws-settings.outputs.my_domain_zone.name
  acl        = "private"
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
resource "aws_s3_bucket" "s3_bucket_image" {
  depends_on = [data.aws_iam_policy_document.iam_policy]
  bucket     = "my-site-image-bucket"
  acl        = "private"
}

########################################################
# S3 Bucket Policy
########################################################
resource "aws_s3_bucket_policy" "bucket_hosting_policy" {
  bucket = aws_s3_bucket.s3_bucket_hosting.id
  policy = data.aws_iam_policy_document.iam_policy[0].json
}
resource "aws_s3_bucket_policy" "bucket_image_policy" {
  bucket = aws_s3_bucket.s3_bucket_image.id
  policy = data.aws_iam_policy_document.iam_policy[1].json
}
locals {
  s3_buckets_arn = [
    "arn:aws:s3:::${data.terraform_remote_state.my-aws-settings.outputs.my_domain_zone.name}",
    "arn:aws:s3:::my-site-image-bucket",
  ]
}
data "aws_iam_policy_document" "iam_policy" {
  count = length(local.s3_buckets_arn)
  statement {
    sid    = "Allow CloudFront"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    actions = ["s3:GetObject"]
    resources = [
      "${local.s3_buckets_arn[count.index]}/*",
    ]
  }
}
