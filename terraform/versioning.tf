resource "aws_s3_bucket_versioning" "devsecops_lab" {
  bucket = aws_s3_bucket.devsecops_lab.id

  versioning_configuration {
    status = "Enabled"
  }
}
