variable "bucket_name" {
  type = string
  default = "static-website-bucket"
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

