resource "null_resource" "package-lambda" {
  triggers = {
    time                     = timestamp()
    function_file_change     = filebase64sha256("../../lambda/clean_image.py")
    # requirements_file_change = filebase64sha256("../../lambda/requirements.txt")
  }

  provisioner "local-exec" {
    command = "bash ./package.sh"
  }
}

data "null_data_source" "lambda-sync" {
  inputs = {
    file    = "${path.cwd}/lambda.zip"
    trigger = "${null_resource.package-lambda.id}" # this is for sync only
  }
}

resource "aws_s3_bucket_object" "lambda" {
  bucket = "waiariki-lambda-code"
  key    = "lambdas/lambda.zip"
  source = "${path.cwd}/lambda.zip"

  metadata = {
    hash = filebase64sha256(data.null_data_source.lambda-sync.outputs["file"])
  }

  depends_on = [null_resource.package-lambda]
}
