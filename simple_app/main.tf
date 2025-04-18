# S3 bucket for terraform state
resource "aws_s3_bucket" "terraform_practice" {
  bucket        = var.state_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_practice_versioning" {
  bucket = var.state_bucket_name
  versioning_configuration {
    status = "Disabled"
  }
}

# S3 bucket to input/output data
resource "aws_s3_bucket" "input_data" {
  bucket        = "input-data-terraform-practice-101"
  force_destroy = true
}

resource "aws_s3_bucket" "output_data" {
  bucket        = "output-data-terraform-practice-101"
  force_destroy = true
}

# SNS publish topic policies
data "aws_iam_policy_document" "topic_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.input_data_topic.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.input_data.arn]
    }
  }
}

# SNS topic for S3 input notification
resource "aws_sns_topic" "input_data_topic" {
  name         = "input_data_topic"
  display_name = "input-data-topic"
}

# Attach SNS publish policy to s3 bucket
resource "aws_sns_topic_policy" "input_sns_topic_policy" {
  arn    = aws_sns_topic.input_data_topic.arn
  policy = data.aws_iam_policy_document.topic_policy_document.json
}

# S3 bucket notification
resource "aws_s3_bucket_notification" "input_bucket_notification" {
  bucket = aws_s3_bucket.input_data.bucket
  topic {
    events        = ["s3:ObjectCreated:*"]
    topic_arn     = aws_sns_topic.input_data_topic.arn
    filter_prefix = "input/"
  }
  depends_on = [aws_sns_topic_policy.input_sns_topic_policy]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "tf_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  #   managed_policy_arns = [
  #     "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess",
  #     "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  #   ]
}

# Attach custom read s3 bucket policies to the IAM role
resource "aws_iam_role_policy" "lambda_read_s3_policy" {
  name = "lambda_read_s3_input_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.input_data.arn}/*"
        ]
      }
    ]
  })
}

# Attach AWS managed policies to the IAM role
resource "aws_iam_role_policy_attachments_exclusive" "lambda_policy_attachments" {
  role_name = aws_iam_role.iam_for_lambda.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# Lambda function files and configurations
data "archive_file" "lambda_file" {
  type        = "zip"
  source_dir  = "_lambda/code"
  output_path = "output/_lambda/code/lambda_function_payload.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "tf_lambda_function_test"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_file.output_path
  source_code_hash = data.archive_file.lambda_file.output_base64sha256
}

# Lambda function permissions to invoke from SNS
resource "aws_lambda_permission" "sns_invoke_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.input_data_topic.arn
}

# SNS topic subscription to lambda function
resource "aws_sns_topic_subscription" "lambda_subscription" {
  endpoint  = aws_lambda_function.lambda_function.arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.input_data_topic.arn
}
