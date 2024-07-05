variable "env_name" {
  type = string
  default = "databricks workspace"
}

variable "user_name" {
    type = string
    description = "firstname.lastname"
}

variable "region" { 
  type = string
  default = "ap-northeast-2"
}

variable "client_id" {
    type = string
}
variable "client_secret" {
    type = string
}

variable "databricks_account_id" {
  type = string
  description = "Databricks account id from accounts console"
}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "[prefix value]"
  tags = {
    Owner = "${var.user_name}"
    Environment = "${var.env_name}"
    }
  force_destroy = true #destroy root bucket when deleting stack?
}