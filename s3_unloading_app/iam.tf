# Two most common way to create policy:
# 1. create standalone policy (from jsonendcode) and attach it to the role (reuseable)
# 2. from aws_iam policy document to generate the policy and attach it to the role

# Policy for unloading data from Snowflake to S3
resource "aws_iam_policy" "loader_policy" {
  name        = "unloading_s3_policy"
  path        = "/"
  description = "IAM policy for unloading data from Snowflake to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = [
          aws_s3_bucket.unloaded_bucket.arn,
          "${aws_s3_bucket.unloaded_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.unloaded_bucket.arn
        ]
        Condition = {
          StringLike = {
            "s3:prefix" = ["*"] # Allow all prefixes within bucket
          }
        }
      }
    ]
  })
  tags = var.common_tags
}

# IAM role for Snowflake to assume
resource "aws_iam_role" "unloading_role" {
  name = "unloading_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          "AWS" : "arn:aws:iam::333861696097:user/d9mz0000-s"
          # "AWS" : var.aws_account_id # todo: temporarily current AWS account ID, modify the trust relationship later
        }
        "Condition" = {
          "StringEquals" = {
            "sts:ExternalId" = var.snowflake_external_id
            # "sts:ExternalId" = "0000" # todo: placeholder ID such as 0000, modify the trust relationship later
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "unloading_role_policy_attachment" {
  role       = aws_iam_role.unloading_role.name
  policy_arn = aws_iam_policy.loader_policy.arn
}