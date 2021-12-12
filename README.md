# clean-s3-metadata

This repository contains a lambda function and adequate infrastructure to deploy the lambda function that removes exif metadata from a photo

# Lambda
The lambda code is contained within the lambda directory, using the Pillow library to do the removal.

# Terraform
This is split in to two sections; package and infra.

The Infra contains all the infrastructure around the Lambda; S3 bucket, kms keys, lambda function and IAM users

The Package contains elements to package the lambda function

*Note*:The package does not current run correctly on lambda as this was timing out or running in to import errors
