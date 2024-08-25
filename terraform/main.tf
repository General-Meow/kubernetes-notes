provider "aws" {
  region                      = "us-east-1"
  access_key                  = "fake"
  secret_key                  = "fake"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_force_path_style         = true  #needed to use path style instead of domain style


//  endpoints {
//    dynamodb = "http://localhost:31566"
//    lambda   = "http://localhost:31566"
//    kinesis  = "http://localhost:31566"
//    s3       = "http://localhost:31566"
//    dynamodbstreams       = "http://localhost:31566"
//    iam      = "http://localhost:31566"
//    cloudwatch            = "http://localhost:31566"
//
//  }

  endpoints {
    dynamodb = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    kinesis  = "http://localhost:4566"
    s3       = "http://localhost:4566"
    dynamodbstreams       = "http://localhost:4566"
    iam      = "http://localhost:4566"
    cloudwatch            = "http://localhost:4566"

  }
}

//resource "aws_s3_bucket" "my-bucket" {
//  bucket = "my-bucket"
//  acl    = "private"
//
//  tags = {
//    Name        = "My bucket"
//    Environment = "Local"
//  }
//}
//
//resource "aws_dynamodb_table" "my-table" {
//  name = "my-table"
//  hash_key = "my-id"
//  write_capacity = 1
//  read_capacity = 1
//
//  attribute {
//    name = "my-id"
//    type = "S"
//  }
//
//  stream_enabled = true
//  stream_view_type = "NEW_AND_OLD_IMAGES"
//
//  replica {
//    region_name = "us-east-1"
//  }
//}

resource "aws_dynamodb_table" "stores" {
  name = "Stores"
  hash_key = "id"
  write_capacity = 1
  read_capacity = 1

  attribute {
    name = "id"
    type = "S"
  }

  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

//  replica {
//    region_name = "us-east-1"
//  }
}


//resource "aws_iam_role" "iam_for_lambda" {
//  name = "iam_for_lambda"
//
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "lambda.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": ""
//    }
//  ]
//}
//EOF
//}

//data "archive_file" "my_lambda_zip" {
//  type        = "zip"
//  source_file = "lambdafile.py"
//  output_path = "lambda_function.zip"
//}


//resource "aws_lambda_function" "my-lambda" {
//  filename      = "my_lambda_package.zip"
//  function_name = "my-lambda-function"
//  role          = aws_iam_role.iam_for_lambda.arn
//  handler       = "lambdafile.handler_name"
//
////  source_code_hash = data.archive_file.my_lambda_zip.output_base64sha256
//  source_code_hash = filebase64sha256("my_lambda_package.zip")
//  runtime = "python3.7"
//
//  environment {
//    variables = {
//      BLAH = "blah value"
//      KAFKA_HOST = "192.168.1.105"
//      KAFKA_PORT = "9092"
//      KAFKA_TOPIC = "test"
//    }
//  }
//}


//resource "aws_lambda_event_source_mapping" "my-event-mapping" {
//  event_source_arn  = aws_dynamodb_table.my-table.stream_arn
//  function_name     = aws_lambda_function.my-lambda.arn
//  starting_position = "LATEST"
//}


//resource "aws_lambda_event_source_mapping" "stores-event-mapping" {
//  event_source_arn  = aws_dynamodb_table.stores.stream_arn
//  function_name     = aws_lambda_function.my-lambda.arn
//  starting_position = "LATEST"
//}
