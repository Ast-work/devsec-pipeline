resource "aws_s3_bucket_server_side_encryption_configuration" "devsecops_lab" {
  bucket = aws_s3_bucket.devsecops_lab.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }

    bucket_key_enabled = true
  }
}
