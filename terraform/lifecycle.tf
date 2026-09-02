resource "aws_s3_bucket_lifecycle_configuration" "devsecops_lab" {
  bucket = aws_s3_bucket.devsecops_lab.id

  rule {
    id     = "cleanup-old-objects"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

  }
}
