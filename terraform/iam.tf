data "aws_iam_policy_document" "trusted_entity" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "lambda" {
  name               = "lambda-vpc-sqs-role" # Role name
  assume_role_policy = "${data.aws_iam_policy_document.trusted_entity.json}" # Trusted entities
}


resource "aws_iam_role_policy_attachment" "attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  ])

  role       = aws_iam_role.lambda.name
  policy_arn = each.value
}