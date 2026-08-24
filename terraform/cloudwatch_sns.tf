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
