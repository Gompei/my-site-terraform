resource "aws_api_gateway_account" "api" {
  cloudwatch_role_arn = aws_iam_role.api_gateway.arn
}

data "aws_iam_policy_document" "api_gateway_1" {
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
  assume_role_policy = data.aws_iam_policy_document.api_gateway_1.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_1" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "my-site-api-gateway-rest"
  description = "my-site-api-gateway-rest"
}

resource "aws_api_gateway_resource" "api" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "api" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.api.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method_response" "hello_world" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_method.api]
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.api.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  depends_on        = [aws_api_gateway_integration.api]
  stage_description = "my-site-api-gateway-deployment"
  stage_name        = "v1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method_settings" "api" {
  depends_on = [aws_api_gateway_account.api]

  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api.stage_name
  settings {
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "site-api.${var.root_domain}"
  regional_certificate_arn = aws_acm_certificate_validation.certificate.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

resource "aws_api_gateway_api_key" "api" {
  name    = "my-site-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "api" {
  name       = "my-site-usage-plan"
  depends_on = [aws_api_gateway_deployment.api]

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.api.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "api" {
  key_id        = aws_api_gateway_api_key.api.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api.id
}