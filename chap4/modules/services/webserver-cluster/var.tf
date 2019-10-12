variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "elb_port" {
  description = "The port ELB uses for HTTP requests"
  default = 80
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}

variable "webserver_remote_state_key" {
  description = "The path for the webserver's remote state in S3"
}