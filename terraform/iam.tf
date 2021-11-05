locals {
  github_owner      = "Gompei"
  github_repo_front = "my-site"
  github_repo_api   = "my-site-api"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
  client_id_list  = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions" {
  name               = "my-site-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_1.json
}

data "aws_iam_policy_document" "github_actions_1" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.id]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.github_owner}/${local.github_repo_front}:*",
        "repo:${local.github_owner}/${local.github_repo_api}:*",
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "my-site-github-actions-role-policy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_2.json
}

data "aws_iam_policy_document" "github_actions_2" {
  statement {
    effect    = "Allow"
    resources = [aws_s3_bucket.bucket.arn]
    actions   = ["*"]
  }

  statement {
    effect    = "Allow"
    resources = [aws_lambda_function.api.arn]
    actions   = ["*"]
  }

  statement {
    effect    = "Allow"
    resources = [aws_cloudfront_distribution.distribution.arn]
    actions   = ["*"]
  }
}
