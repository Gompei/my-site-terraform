########################################################
# Lambda
########################################################
resource "aws_lambda_function" "api" {
  function_name    = "my-site-api"
  handler          = "handler"
  role             = aws_iam_role.lambda.arn
  publish          = true
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 3
  s3_bucket        = data.terraform_remote_state.my-aws-settings.outputs.lambda_bucket_ap-northeast-1.bucket
  s3_key           = "my-site/lambda.zip"
  source_code_hash = aws_s3_bucket_object.lambda.etag
  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}
resource "aws_iam_role" "lambda" {
  name                = "my-site-api-role"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}
resource "aws_iam_role_policy" "lambda" {
  name   = "my-site-api-role-dynamo-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_role.json
}
data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"
    resources = [
      aws_dynamodb_table.dynamodb_table.arn,
    ]
    actions = ["*"]
  }
}

########################################################
# Lambda Source Upload
########################################################
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

########################################################
# Lambda Permission
########################################################
resource "aws_lambda_permission" "list_get" {
  statement_id  = "allow-api-gateway-list-get"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/GET/${aws_api_gateway_resource.root_path["article"].path_part}/${aws_api_gateway_resource.first_path["list"].path_part}"
}
resource "aws_lambda_permission" "article_get" {
  statement_id  = "allow-api-gateway-article-get"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/GET/${aws_api_gateway_resource.root_path["article"].path_part}/*"
}
