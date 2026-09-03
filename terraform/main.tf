terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "devsecops_lab" {
  #checkov:skip=CKV_AWS_144:S3 cross-region replication is not required for this development lab

  bucket = "devsecops-lab-demo-bucket"

  tags = {
    Name        = "DevSecOps Lab"
    Environment = "Lab"
  }
}
