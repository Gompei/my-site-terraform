resource "aws_lambda_function" "api" {
  depends_on = [aws_iam_role_policy_attachment.lambda_1]

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

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda" {
  name               = "my-site-api-role"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_1" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_2" {
  name   = "my-site-api-role-dynamo-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_2.json
}

data "aws_iam_policy_document" "lambda_2" {
  statement {
    effect = "Allow"
    resources = [
      aws_dynamodb_table.dynamodb_table.arn,
    ]
    actions = ["*"]
  }
}

// lambda呼び出し権限設定
resource "aws_lambda_permission" "put_article_path" {
  statement_id  = "allow-api-gateway-put-article-path"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/PUT/${aws_api_gateway_resource.root_path["article"].path_part}"
}
resource "aws_lambda_permission" "test_path" {
  statement_id  = "allow-api-gateway-test-path"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/GET/${aws_api_gateway_resource.root_path["test"].path_part}"
}
resource "aws_lambda_permission" "each_path" {
  for_each      = toset(["list"])
  statement_id  = "allow-api-gateway-${each.value}-path"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/GET/${aws_api_gateway_resource.root_path["article"].path_part}/${aws_api_gateway_resource.first_path[each.value].path_part}"
}
resource "aws_lambda_permission" "article_path" {
  for_each      = toset(["GET"])
  statement_id  = "allow-api-gateway-${each.value}-article-path"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/${each.value}/${aws_api_gateway_resource.root_path["article"].path_part}/*"
}
