output "elb_dns_name" {
  value = "${aws_elb.elb_example.dns_name}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.example.name}"
}