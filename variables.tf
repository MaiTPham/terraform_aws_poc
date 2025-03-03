variable "shared_credentials_file" {
  description = "The path to the shared credentials file"
  type        = string
  default     = "~/.aws/credentials"
  sensitive   = true
  nullable    = false
}

variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string
  default     = "self"
  nullable    = false
}

variable "region" {
  description = "The AWS region to use"
  type        = string
  default     = "us-east-1"
  nullable    = false
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket for storing the Terraform state"
  type        = string
  default     = "terraform-practice-101"
  nullable    = false
}

