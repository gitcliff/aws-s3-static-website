
resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_gateway_name
  protocol_type = var.api_gateway_protocol_type
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = var.api_gateway_stage_name
  auto_deploy = var.api_gateway_stage_auto_deploy
}

# Integration with backend AWS Lambda function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = var.api_gateway_integration_type
  integration_uri        = aws_lambda_function.backend_logic.arn
  payload_format_version = var.api_gateway_payload_format_version
}

# Dynamic fallback route routing /api/{proxy+} to the Lambda function
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = var.api_gateway_route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Trust statement enabling API Gateway execution calls to Lambda
resource "aws_lambda_permission" "api_gw_permission" {
  statement_id  = var.api_gateway_lambda_permission_statement_id
  action        = var.api_gateway_lambda_permission_action
  function_name = aws_lambda_function.backend_logic.function_name
  principal     = var.api_gateway_lambda_permission_principal
  source_arn    = "${aws_apigatewayv2_api.http_api.arn}/*/*"
}
