resource "aws_lambda_function" "api" {
  depends_on = [aws_iam_role_policy_attachment.lambda_1]

  function_name    = "my-site-api"
  handler          = "handler"
  role             = aws_iam_role.lambda.arn
  publish          = true
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 3
  s3_bucket        = "gompei-lambda-management-bucket-us-east-1"
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
      "${aws_dynamodb_table.main.arn}/*"
    ]
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]
  }
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/${aws_api_gateway_resource.api.path_part}"
}