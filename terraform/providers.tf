terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6"
    }
  }
}

locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("../../config.env")) : tuple[0] => sensitive(tuple[1]) }
}


provider "aws" {
    region     = "eu-west-2"
    profile    = "default"
}
