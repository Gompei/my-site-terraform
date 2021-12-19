########################################################
# API Gateway
########################################################
resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name        = "my-site-api-gateway-rest"
  description = "my-site-api-gateway-rest"
}

########################################################
# Cloud Watch
########################################################
resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway.arn
}
resource "aws_iam_role" "api_gateway" {
  name                = "my-site-api-gateway-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    effect = "Allow"
  }
}

########################################################
# API Gateway Error Response
########################################################
resource "aws_api_gateway_gateway_response" "default_4xx_response" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  response_type = "DEFAULT_4XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}
resource "aws_api_gateway_gateway_response" "default_5xx_response" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  response_type = "DEFAULT_5XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
}

########################################################
# API Gateway Resource Path
########################################################
locals {
  root_path  = ["article"]
  first_path = ["{articleID}", "list"]
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

########################################################
# API Gateway Method
########################################################
resource "aws_api_gateway_method" "list_get" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.first_path["list"].id
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
resource "aws_api_gateway_method" "options" {
  for_each         = toset(local.first_path)
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.first_path[each.value].id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

########################################################
# API Gateway Integration
########################################################
resource "aws_api_gateway_integration" "list_get" {
  depends_on              = [aws_api_gateway_method.list_get]
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.first_path["list"].id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}
resource "aws_api_gateway_integration" "article_get" {
  depends_on              = [aws_api_gateway_method.article_get]
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.first_path["{articleID}"].id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
  request_parameters = {
    "integration.request.path.id" = "method.request.path.articleID"
  }
}
resource "aws_api_gateway_integration" "options" {
  for_each    = toset(local.first_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path[each.value].id
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

########################################################
# API Gateway Method Response
########################################################
resource "aws_api_gateway_method_response" "list_get" {
  depends_on  = [aws_api_gateway_method.list_get]
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path["list"].id
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
resource "aws_api_gateway_method_response" "article_get" {
  depends_on  = [aws_api_gateway_method.article_get]
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path["{articleID}"].id
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
resource "aws_api_gateway_method_response" "options" {
  for_each    = toset(local.first_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path[each.value].id
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

########################################################
# API Gateway Integration Response
########################################################
resource "aws_api_gateway_integration_response" "options" {
  for_each    = toset(local.first_path)
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.first_path[each.value].id
  http_method = aws_api_gateway_method.options[each.value].http_method
  status_code = aws_api_gateway_method_response.options[each.value].status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

########################################################
# Deploy API Gateway
########################################################
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.list_get,
    aws_api_gateway_integration.article_get,
    aws_api_gateway_integration.options
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  // 常にデプロイ
  stage_description = "timestamp = ${timestamp()}"
  stage_name        = "api"
  lifecycle {
    create_before_destroy = true
  }
}

########################################################
# API Gateway Method Settings
########################################################
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

########################################################
# API Key Settings
########################################################
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
