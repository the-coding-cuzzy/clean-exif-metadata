resource "aws_kms_key" "s3" {
  description             = "Encrypts S3 data"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3_default_encryption" {
  name          = "alias/s3_default_encryption"
  target_key_id = aws_kms_key.s3.id
}
