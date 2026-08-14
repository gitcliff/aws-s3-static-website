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

variable "oac_description" {
  description = "Description of the CloudFront Origin Access Control"
  type        = string
  default     = "static website Policy"
}

