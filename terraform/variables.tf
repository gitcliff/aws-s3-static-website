variable "bucket_name" {
  type = string
  default = "static-website-bucket"
}

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "oac_name" {
  description = "Name of the CloudFront Origin Access Control"
  type        = string
  default     = "demo-oac"
}

variable "bucket_tag" {
  description = "The tag for the s3 bucket"
  type = string
  default = "My bucket"
}

variable "oac_description" {
  description = "Description of the CloudFront Origin Access Control"
  type        = string
  default     = "static website Policy"
}

variable "lambda_execution_role" {
  description = "Lambda Execution Role name"
  type        = string
  default     = "site-lambda-execution-role"
}

variable "lambda_cloudwatch_dynameDB_policy_name" {
  description = "Lambda policy name for cloudwatch and dynamoDB"
  type        = string
  default     = "site-lambda-permissions-policy"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway HTTP API"
  type        = string
  default     = "serverless_lambda_gw"
}

variable "api_gateway_protocol_type" {
  description = "Protocol type used by the API Gateway API"
  type        = string
  default     = "HTTP"
}

variable "api_gateway_stage_name" {
  description = "Deployment stage name for the API Gateway API"
  type        = string
  default     = "serverless_lambda_stage"
}

variable "api_gateway_stage_auto_deploy" {
  description = "Whether API Gateway automatically deploys stage changes"
  type        = bool
  default     = true
}

variable "api_gateway_integration_type" {
  description = "Integration type for the backend Lambda function"
  type        = string
  default     = "AWS_PROXY"
}

variable "api_gateway_payload_format_version" {
  description = "Payload format version passed to the Lambda integration"
  type        = string
  default     = "2.0"
}

variable "api_gateway_route_key" {
  description = "Route key that forwards API requests to the Lambda integration"
  type        = string
  default     = "ANY /api/{proxy+}"
}

variable "api_gateway_lambda_permission_statement_id" {
  description = "Statement ID for the API Gateway Lambda permission"
  type        = string
  default     = "AllowExecutionFromCloudWatch"
}

variable "api_gateway_lambda_permission_action" {
  description = "Lambda action granted to API Gateway"
  type        = string
  default     = "lambda:InvokeFunction"
}

variable "api_gateway_lambda_permission_principal" {
  description = "Principal allowed to invoke the backend Lambda function"
  type        = string
  default     = "apigateway.amazonaws.com"
}

variable "lambda_function_name" {
  description = "Name of the backend Lambda function"
  type        = string
  default     = "cliff-backend-handler"
}

variable "lambda_handler" {
  description = "Handler used by the backend Lambda function"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Runtime used by the backend Lambda function"
  type        = string
  default     = "python3.12"
}



variable "lambda_source_filename" {
  description = "Filename of the source file inside the Lambda package"
  type        = string
  default     = "index.js"
}

variable "alert_email" {
  type = string
  default = "gitacliff48@gmail.com"
  
}

