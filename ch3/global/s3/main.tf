provider "aws" {
  region = "us-west-2"
}


resource "aws_s3_bucket" "tf_state" {
  bucket = "aduss-tfur-state"

  lifecycle {
    # prevent_destroy = true
    prevent_destroy = false
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_dynamodb_table" "tf_locks" {
  name         = "aduss_tfur_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}


# terraform {
#   backend "s3" {
#     bucket = "aduss-tfur-state"
#     key    = "global/s3/terraform.tfstate"
#     region = "us-west-2"

#     dynamodb_table = "aduss_tfur_locks"
#     encrypt        = true
#   }
# }

