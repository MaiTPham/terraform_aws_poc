variable "shared_credentials_file" {
  description = "The path to the shared credentials file"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "shared_config_file" {
  description = "The path to the shared config file"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string
  nullable    = false
}

variable "region" {
  description = "The AWS region to use"
  type        = string
  default     = "us-east-1"
  nullable    = false
}

variable "aws_account_id" {
  description = "The AWS account ID to use"
  type        = string
  nullable    = false
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket for storing the Terraform state"
  type        = string
  default     = "terraform-practice-101"
  nullable    = false
}

variable "common_tags" {
  description = "Common tags to apply to all terraform-generated resources"
  type        = map(string)
  default = {
    Environment    = "self"
    Infrastructure = "terraform"
  }
  nullable = false
}

