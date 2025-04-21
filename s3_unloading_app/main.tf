# S3 bucket for terraform state
# resource "aws_s3_bucket" "terraform_practice" {
#   bucket        = var.state_bucket_name
#   force_destroy = true
# }
#
# resource "aws_s3_bucket_versioning" "terraform_practice_versioning" {
#   bucket = var.state_bucket_name
#   versioning_configuration {
#     status = "Disabled"
#   }
# }