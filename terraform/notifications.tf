resource "aws_sns_topic" "s3_events" {

  name              = "devsecops-s3-events"
  kms_master_key_id = aws_kms_key.s3.arn

}

resource "aws_s3_bucket_notification" "devsecops_lab" {
  bucket = aws_s3_bucket.devsecops_lab.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn

    events = [
      "s3:ObjectCreated:*"
    ]
  }

  depends_on = [
    aws_sns_topic.s3_events
  ]
}
