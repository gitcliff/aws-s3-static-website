
# AWS WAFv2 Web ACL deployed at the CloudFront Edge
resource "aws_wafv2_web_acl" "waf" {
  name        = "cliff-cloudfront-waf"
  description = "Edge firewall protecting CloudFront origins"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Production-ready baseline: AWS Core Managed Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "CliffCloudFrontWAFMetric"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Custom domain
  aliases = [local.domain_name]

  origin {
    domain_name              = aws_s3_bucket.first_bucket.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.first_bucket.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Origin 2: API Gateway Backend
  origin {
    domain_name = replace(aws_apigatewayv2_stage.prod.invoke_url, "https://", "")
    origin_id   = "APIGateway-Backend"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.first_bucket.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    # Force HTTP → HTTPS
    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # HTTPS certificate
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.website_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}