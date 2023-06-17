terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = "eu-west-1"
}

//read from the environment variables
variable "secret" {}
variable "aws_account_id" {}

resource "aws_iam_role" "kms_access_for_lambda" {
  name = "kms_access_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


resource "aws_kms_key" "symmetric_key" {
  description             = "Symmetric key to encrypt and decrypt the secrets"
  deletion_window_in_days = 7
}

resource "aws_kms_ciphertext" "secret" {
  key_id    = aws_kms_key.symmetric_key.key_id
  plaintext = var.secret
  context = {
    LambdaFunctionName = "tutorial_lambda"
  }
}

resource "aws_kms_grant" "tutorial_lambda_grant" {
  name              = "tutorial_iam_lambda_grant"
  key_id            = aws_kms_key.symmetric_key.key_id
  grantee_principal = aws_iam_role.kms_access_for_lambda.arn
  operations        = ["Decrypt"]
}


resource "aws_lambda_function" "tutorial_lambda" {
  filename         = "package.zip"
  function_name    = "tutorial_lambda"
  role             = aws_iam_role.kms_access_for_lambda.arn
  handler          = "lambda_function.handler"
  source_code_hash = filebase64sha256("package.zip")
  runtime          = "python3.9"
  environment {
    variables = {
        SECRET = aws_kms_ciphertext.secret.ciphertext_blob
    }
  }
}


resource "aws_lambda_function_url" "tutorial_lambda_url" {
  function_name      = aws_lambda_function.tutorial_lambda.arn
  authorization_type = "NONE"
}

output "function_url" {
  description = "Function URL."
  value       = aws_lambda_function_url.tutorial_lambda_url.function_url
}