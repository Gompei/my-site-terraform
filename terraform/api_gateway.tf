resource "aws_api_gateway_rest_api" "api" {
  name        = "my-site-api-gateway-rest"
  description = "my-site-api-gateway-rest"
}

resource "aws_api_gateway_resource" "api" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "rest_get" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.api.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.rest_get.http_method
  integration_http_method = "ANY"
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

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "site-api.${var.root_domain}"
  regional_certificate_arn = aws_acm_certificate_validation.certificate.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}
