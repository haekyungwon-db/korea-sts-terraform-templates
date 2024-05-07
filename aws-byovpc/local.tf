locals {
  vpc_cidr = "10.10.0.0/16"
  root_bucket_name = "databricks-customer001-rootbucket"
  prefix = "databricks-poc"
  tags = {
    Owner = "databricks-${var.user_name}"
    Environment = "${var.env_name}"

    }
  force_destroy = true #destroy root bucket when deleting stack?
}