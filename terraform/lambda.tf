//resource "aws_lambda_function" "api" {
//  function_name = "my-site-api"
//  role          = aws_iam_role.lambda.arn
//}
//
//data "aws_iam_policy_document" "lambda" {
//  statement {
//    actions = ["sts:AssumeRole"]
//
//    principals {
//      type        = "Service"
//      identifiers = ["lambda.amazonaws.com"]
//    }
//    effect = "Allow"
//  }
//}
//resource "aws_iam_role" "lambda" {
//  name = "my-site-api-role"
//  assume_role_policy = data.aws_iam_policy_document.lambda.json
//}
//
//resource "aws_lambda_permission" "lambda" {
//  statement_id  = "AllowAPIGatewayInvoke"
//  action        = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.api.function_name
//  principal     = "apigateway.amazonaws.com"
//}
