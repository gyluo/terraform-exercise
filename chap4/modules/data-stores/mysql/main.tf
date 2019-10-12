resource "aws_db_instance" "example" {
  engine = "mysql"
  allocated_storage = 10
  instance_class = "${var.db_instance}"
  name = "${var.db_name}_database"
  username = "admin"
  password = "${var.db_password}"
  skip_final_snapshot = true
}