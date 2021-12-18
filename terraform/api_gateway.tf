// API Gateway作成
resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name        = "my-site-api-gateway-rest"
  description = "my-site-api-gateway-rest"
}

// Cloud Watch設定
resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway.arn
}
data "aws_iam_policy_document" "api_gateway" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    effect = "Allow"
  }
}
resource "aws_iam_role" "api_gateway" {
  name               = "my-site-api-gateway-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway.json
}
resource "aws_iam_role_policy_attachment" "api_gateway" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

// リソース作成(APIパス)
locals {
  root_path  = ["test", "article"]
  first_path = ["{articleID}", "search", "list"]
}
resource "aws_api_gateway_resource" "root_path" {
  for_each    = toset(local.root_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  path_part   = each.value
}
resource "aws_api_gateway_resource" "first_path" {
  for_each    = toset(local.first_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  parent_id   = aws_api_gateway_resource.root_path["article"].id
  path_part   = each.value
}

// メソッド作成
resource "aws_api_gateway_method" "article_put" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.root_path["article"].id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}
resource "aws_api_gateway_method" "test_get" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.root_path["test"].id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}
resource "aws_api_gateway_method" "each_get" {
  for_each         = toset(["list"])
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.first_path[each.value].id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}
resource "aws_api_gateway_method" "article_get" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.first_path["{articleID}"].id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.articleID" = true
  }
}

// 統合タイプ設定
resource "aws_api_gateway_integration" "article_put" {
  depends_on = [aws_api_gateway_method.article_put]

  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.root_path["article"].id
  http_method             = "PUT"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}
resource "aws_api_gateway_integration" "test_get" {
  depends_on = [aws_api_gateway_method.test_get]

  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.root_path["test"].id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}
resource "aws_api_gateway_integration" "each_get" {
  depends_on = [aws_api_gateway_method.each_get]

  for_each                = toset(["list"])
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.first_path[each.value].id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}
resource "aws_api_gateway_integration" "article_any" {
  depends_on = [
    aws_api_gateway_method.article_get
  ]

  for_each                = toset(["GET"])
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.first_path["{articleID}"].id
  http_method             = each.value
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
  request_parameters = {
    "integration.request.path.id" = "method.request.path.articleID"
  }
}

// レスポンス設定
resource "aws_api_gateway_method_response" "article_put_response" {
  depends_on = [aws_api_gateway_method.article_put]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.root_path["article"].id
  http_method = "PUT"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_method_response" "test_response" {
  depends_on = [aws_api_gateway_method.test_get]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.root_path["test"].id
  http_method = "GET"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_method_response" "each_response" {
  depends_on = [aws_api_gateway_method.each_get]

  for_each    = toset(["list"])
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path[each.value].id
  http_method = "GET"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_method_response" "article_any_response" {
  depends_on = [
    aws_api_gateway_method.article_get
  ]

  for_each    = toset(["GET"])
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path["{articleID}"].id
  http_method = each.value
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

// CORS設定
resource "aws_api_gateway_method" "options" {
  for_each      = toset(local.root_path)
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.root_path[each.value].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "options_first_path" {
  for_each      = toset(local.first_path)
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.first_path[each.value].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "options" {
  for_each    = toset(local.root_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.root_path[each.value].id
  http_method = aws_api_gateway_method.options[each.value].http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_method_response" "options_first_path" {
  for_each    = toset(local.first_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path[each.value].id
  http_method = aws_api_gateway_method.options_first_path[each.value].http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "options" {
  for_each    = toset(local.root_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.root_path[each.value].id
  http_method = aws_api_gateway_method.options[each.value].http_method
  status_code = aws_api_gateway_method_response.options[each.value].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
resource "aws_api_gateway_integration_response" "options_first_path" {
  for_each    = toset(local.first_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path[each.value].id
  http_method = aws_api_gateway_method.options_first_path[each.value].http_method
  status_code = aws_api_gateway_method_response.options_first_path[each.value].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
resource "aws_api_gateway_integration" "options_mock" {
  for_each    = toset(local.root_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.root_path[each.value].id
  http_method = aws_api_gateway_method.options[each.value].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}
resource "aws_api_gateway_integration" "options_mock_first_path" {
  for_each    = toset(local.first_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path[each.value].id
  http_method = aws_api_gateway_method.options_first_path[each.value].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

// デプロイ
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  depends_on = [
    aws_api_gateway_integration.test_get,
    aws_api_gateway_integration.each_get,
    aws_api_gateway_integration.article_any,
    aws_api_gateway_integration.options_mock
  ]
  // 常にデプロイ
  stage_description = "timestamp = ${timestamp()}"
  stage_name        = "api"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_method_settings" "method_settings" {
  depends_on = [aws_api_gateway_account.account]

  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  settings {
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}

// API設定
resource "aws_api_gateway_api_key" "api_key" {
  name    = "my-site-api-key"
  enabled = true
}
resource "aws_api_gateway_usage_plan" "usage_plan" {
  depends_on = [aws_api_gateway_deployment.deployment]

  name = "my-site-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
    stage  = aws_api_gateway_deployment.deployment.stage_name
  }
}
resource "aws_api_gateway_usage_plan_key" "api" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
