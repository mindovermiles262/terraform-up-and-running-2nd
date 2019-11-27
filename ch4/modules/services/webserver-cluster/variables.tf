variable "server_port" {
  description = "The port the webserver will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name used for all cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the DB's remote state in the S3 Bucket"
  type        = string
}

variable "instance_type" {
  description = "The Type of EC2 Instance to run (t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of instances in the cluster"
  type        = number
}

variable "min_size" {
  description = "The maximum number of instances in the cluster"
  type        = number
}

