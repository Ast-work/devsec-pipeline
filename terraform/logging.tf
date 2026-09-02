resource "aws_s3_bucket" "logs" {
  bucket = "devsecops-lab-logs-bucket"
#checkov:skip=CKV_AWS_144:S3 cross-region replication is not required for this development lab
#checkov:skip=CKV2_AWS_62:Event notifications are not required for the dedicated S3 access-log destination bucket
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_logging" "devsecops_lab" {
  bucket        = aws_s3_bucket.devsecops_lab.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}
