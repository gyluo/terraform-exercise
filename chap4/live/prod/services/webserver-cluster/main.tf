provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-prod"
  remote_state_bucket = "terraform-up-and-running-state-gluo"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
  webserver_remote_state_key = "prod/services/webserver-cluster/terraform.tfstate"
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
  scheduled_action_name = "scale_out_during_business_hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
  scheduled_action_name = "scale_in_at_night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
}

terraform {
  backend "s3" {
    bucket  = "terraform-up-and-running-state-gluo"
    region  = "us-east-1"
    key     = "prod/services/webserver-cluster/terraform.tfstate"
    encrypt = true
  }
}