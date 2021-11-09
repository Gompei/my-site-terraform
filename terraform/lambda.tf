resource "aws_lambda_function" "api" {
  depends_on = [aws_iam_role_policy_attachment.lambda_1]

  function_name    = "my-site-api"
  filename         = "lambda.zip"
  handler          = "handler"
  source_code_hash = sha256(filebase64("lambda.zip"))
  role             = aws_iam_role.lambda.arn
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 3
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

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/${aws_api_gateway_resource.api.path_part}"
}