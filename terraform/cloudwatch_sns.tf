resource "aws_sns_topic" "alerts" {
  name = "cliff-system-alerts-topic"
}

# Subscription endpoints mapping direct emails to system notifications
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Error Alarm monitoring Lambda execution health
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "cliff-lambda-high-error-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Triggered if backend Lambda experiences 5+ internal errors over 5 minutes."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.backend_logic.function_name
  }
}

# CloudWatch Latency Alarm monitoring end-to-end API Gateway response time
resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "cliff-api-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2                     # Requires 2 consecutive periods to prevent false alarms on temporary spikes
  metric_name         = "Latency"             # End-to-end API latency in milliseconds
  namespace           = "AWS/ApiGateway"
  period              = 60                    
  statistic           = "Average"
  threshold           = 1000                  # Triggers if average response time exceeds 1000ms (1 second)
  alarm_description   = "Triggered if API Gateway end-to-end latency averages over 1s for 2 consecutive minutes."
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn] 

  dimensions = {
    ApiName = aws_apigatewayv2_api.http_api.name 
  }
}

