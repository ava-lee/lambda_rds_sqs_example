terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">=0.7.2"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "../secrets.yaml"
}

locals {
  secrets = data.sops_file.secrets.data
  aws_access_id = local.secrets["aws.access_id"]
  aws_access_key = local.secrets["aws.access_key"]
  db_user = local.secrets["rds.user"]
  db_password = local.secrets["rds.password"]
  db_id = local.secrets["rds.id"]
  db_name = local.secrets["rds.db"]
  db_host = local.secrets["rds.host"]
}

provider "aws" {
    region     = "eu-west-2"
    access_key = "${local.aws_access_id}"
    secret_key = "${local.aws_access_key}"
}
