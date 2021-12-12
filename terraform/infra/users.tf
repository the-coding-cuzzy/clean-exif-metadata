resource "aws_iam_user" "user_a" {
  name = "uploader"
}

resource "aws_iam_user_policy" "user_a" {
    name = "downloader"

    user = aws_iam_user.user_a.name
    policy = data.aws_iam_policy_document.s3_policy_user_a.json
}

data "aws_iam_policy_document" "s3_policy_user_a" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObjectAcl"
    ]

    resources = [
      "${aws_s3_bucket.bucket-a.arn}/*",
      "${aws_s3_bucket.bucket-a.arn}"
    ]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      "${aws_kms_key.s3.arn}"
    ]

  }
}

resource "aws_iam_user" "user_b" {
  name = "downloader"
}

resource "aws_iam_user_policy" "user_b" {
    name = "downloader"

    user = aws_iam_user.user_b.name
    policy = data.aws_iam_policy_document.s3_policy_user_b.json
}



data "aws_iam_policy_document" "s3_policy_user_b" {
  statement {
    actions = [
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.bucket-b.arn}/*",
      "${aws_s3_bucket.bucket-b.arn}"
    ]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      "${aws_kms_key.s3.arn}"
    ]
  }
}
