resource "aws_s3_bucket" "unloaded_bucket" {
  bucket = "unloaded-data-terraform-practice-101"
  tags   = var.common_tags
}

resource "aws_s3_bucket_versioning" "unloaded_bucket_versioning" {
  bucket = aws_s3_bucket.unloaded_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}