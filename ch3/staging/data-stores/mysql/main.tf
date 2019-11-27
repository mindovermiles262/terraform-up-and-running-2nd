provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "aduss-tfur-state"
    key    = "staging/data-stores/mysql/terraform.tfstate"
    region = "us-west-2"

    dynamodb_table = "aduss_tfur_locks"
    encrypt        = true
  }
}

resource "aws_db_instance" "tf_db" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "TF_Database"
  username          = "admin"
  password          = var.db_password
}

