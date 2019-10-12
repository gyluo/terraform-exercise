provider "aws" {
  region = "us-east-1"
}

module "mysql" {
  source = "../../../modules/data-stores/mysql"

  remote_state_bucket = "terraform-up-and-running-state-gluo"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
  db_instance = "db.t2.micro"
  db_name = "proddb"
  db_password = "Passw0rd$"
}

terraform {
  backend "s3" {
    bucket  = "terraform-up-and-running-state-gluo"
    region  = "us-east-1"
    key     = "prod/data-stores/mysql/terraform.tfstate"
    encrypt = true
  }
}