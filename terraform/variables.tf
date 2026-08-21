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

