variable "db_password" {
  description = "Admin password for mysql database"
}

variable "db_instance" {
  description = "MySQL database instance"
}

variable "db_name" {
  description = "Name of the database"
}

variable "remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}
