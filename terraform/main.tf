# Create a RDS Database Instance
resource "aws_db_instance" "myinstance" {
  allocated_storage      = 10
  db_name                = local.envs.DB_NAME
  identifier             = local.envs.DB_ID
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = local.envs.DB_USER
  password               = local.envs.DB_PASS
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  publicly_accessible    = true
}

data "aws_db_instance" "database" {
  db_instance_identifier = local.envs.DB_ID
  depends_on             = [aws_db_instance.myinstance]
}

output "rds_address" {
  value = data.aws_db_instance.database.address
}

# Create a Lambda function
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../src/"
  output_path = "lambda.zip"
}


resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "LambdaFunctionWithRDS"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.9"
  handler          = "test_aws.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = ["${aws_security_group.rds.id}"]
  }

  environment {
    variables = {
      RDS_HOST = data.aws_db_instance.database.address
      DB_USER  = data.aws_db_instance.database.master_username
      DB_PASS  = local.envs.DB_PASS
      DB_NAME  = data.aws_db_instance.database.db_name
    }
  }
}

# Create SQS queue
resource "aws_sqs_queue" "lambda_queue" {
  name = "LambdaRDSQueue"
}

# Create event source mapping to read from queue + invoke Lambda function
resource "aws_lambda_event_source_mapping" "event" {
  event_source_arn = aws_sqs_queue.lambda_queue.arn
  function_name    = aws_lambda_function.lambda.arn
  batch_size       = 1
}

# Create CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 3
}
