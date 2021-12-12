
resource "aws_s3_bucket" "bucket-a" {
  bucket = "exif-clean-bucket-a"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false

      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket-a.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.clean-exif-metadata.arn
    events = [
      "s3:ObjectCreated:Put",
      "s3:ObjectCreated:Post",
      "s3:ObjectCreated:Copy"
    ]
    filter_suffix = ".jpg"
  }
}


resource "aws_s3_bucket" "bucket-b" {
  bucket = "exif-clean-bucket-b"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false

      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
