# Dummy file placeholder deployment configuration for code packaging
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "terraform/backend/lambda.zip"
  
  source {
    content  = "exports.handler = async (event) => { return { statusCode: 200, body: JSON.stringify({ count: 42 }) }; };"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "backend_logic" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.visitor_counter.name
    }
  }
}
