provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "elb_port" {
  description = "The port ELB uses for HTTP requests"
  default = 80
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "elb_dns_name" {
  value = "${aws_elb.elb_example.dns_name}"
}

# output "public_ip" {
#   value = "${aws_instance.example.public_ip}"
# }

# resource "aws_instance" "example" {
#   ami = "ami-40d28157"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = ["${aws_security_group.instance.id}"]

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p "${var.server_port}" &
#               EOF

#   tags = {
#     Name = "terraform-example"
#   }
# }

resource "aws_launch_configuration" "example" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }            
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  } 
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.available.names[0]}"]

  load_balancers = ["${aws_elb.elb_example.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "elb_example" {
  name = "terraform-asg-example"
  availability_zones = ["${data.aws_availability_zones.available.names[0]}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]

  listener {
    lb_port = "${var.elb_port}"
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb_sg" {
  name = "terraform-example-elb"

  ingress {
    from_port = "${var.elb_port}"
    to_port = "${var.elb_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

terraform {
  backend "s3" {
    bucket  = "terraform-up-and-running-state-gluo"
    region  = "us-east-1"
    key     = "terraform.tfstate"
    encrypt = true
  }
}