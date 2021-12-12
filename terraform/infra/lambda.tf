resource "aws_iam_role" "lambda" {
  name = "lambda_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda" {
  name        = "lambda-policy"
  description = "A policy for Lambda to access S3 and KMS"

  policy = data.aws_iam_policy_document.lambda-policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda-policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket-a.arn}/*",
      "${aws_s3_bucket.bucket-a.arn}"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
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

  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/clean-exif-metadata:*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda-attachement" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

data "aws_s3_bucket_object" "package" {
  bucket = "waiariki-lambda-code"
  key    = "lambdas/lambda.zip"
}


resource "aws_lambda_function" "clean-exif-metadata" {
  s3_bucket = data.aws_s3_bucket_object.package.bucket
  s3_key    = data.aws_s3_bucket_object.package.key

  function_name = "clean-exif-metadata"
  role          = aws_iam_role.lambda.arn
  handler       = "clean_image.lambda_handler"
  runtime       = "python3.8"

  source_code_hash = data.aws_s3_bucket_object.package.metadata["Hash"]
  kms_key_arn      = aws_kms_key.s3.arn

  layers = [
    "arn:aws:lambda:eu-west-2:770693421928:layer:Klayers-python38-Pillow:14"
  ]

  timeout = 10

  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.bucket-a.id
    }
  }
}

resource "aws_lambda_permission" "allow_bucket_trigger" {
  statement_id  = "AllowExecutionFromS3Bucket1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clean-exif-metadata.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket-a.arn
}
