resource "aws_kms_key" "s3" {

  description             = "KMS key for DevSecOps S3 bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "s3" {
  name          = "alias/devsecops-s3"
  target_key_id = aws_kms_key.s3.key_id
}



data "aws_caller_identity" "current" {}





data "aws_iam_policy_document" "kms_s3" {

  #checkov:skip=CKV_AWS_109:KMS key policy uses account-root administration permissions required for key management
  #checkov:skip=CKV_AWS_111:KMS key administration statement intentionally allows full KMS management to the owning account
  #checkov:skip=CKV_AWS_356:KMS key policies use Resource "*" for key-policy statements; access is constrained by the account-root principal



  statement {
    sid    = "EnableAccountRootPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "s3" {
  key_id = aws_kms_key.s3.id
  policy = data.aws_iam_policy_document.kms_s3.json
}
