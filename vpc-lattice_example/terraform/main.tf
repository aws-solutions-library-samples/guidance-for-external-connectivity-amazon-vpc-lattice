/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- vpc-lattice_example/terraform/main.tf ---

# Local variables
locals {
  vpc_association        = var.ingress_vpc_id == "" ? false : true
  consumer_hostedzone_id = var.consumer_hostedzone_id == "" ? false : true
  ingress_hostedzone_id  = var.ingress_hostedzone_id == "" ? false : true
  ingress_nlb_domainname = var.ingress_nlb_domainname == "" ? false : true
  create_consumer_record = local.consumer_hostedzone_id && local.ingress_nlb_domainname
}

# ---------- AMAZON VPC LATTICE RESOURCES ----------
# Service Network
resource "aws_vpclattice_service_network" "service_network" {
  name      = "service-network-example"
  auth_type = "AWS_IAM"
}

resource "aws_vpclattice_auth_policy" "sn_auth_policy" {
  resource_identifier = aws_vpclattice_service_network.service_network.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "*"
        Effect    = "Allow"
        Principal = "*"
        Resource  = "*"
        Condition = {
          StringNotEqualsIgnoreCase = {
            "aws:PrincipalType" = "anonymous"
          }
        }
      }
    ]
  })
}

# Service
resource "aws_vpclattice_service" "service" {
  name               = "service-example"
  auth_type          = "AWS_IAM"
  custom_domain_name = var.custom_domain_name
  certificate_arn    = var.certificate_arn
}

resource "aws_vpclattice_service_network_service_association" "service_association" {
  service_identifier         = aws_vpclattice_service.service.id
  service_network_identifier = aws_vpclattice_service_network.service_network.id
}

resource "aws_vpclattice_auth_policy" "service_auth_policy" {
  resource_identifier = aws_vpclattice_service.service.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "*"
        Effect    = "Allow"
        Principal = "*"
        Resource  = "*"
        Condition = {
          StringNotEqualsIgnoreCase = {
            "aws:PrincipalType" = "anonymous"
          }
        }
      }
    ]
  })
}

resource "aws_vpclattice_access_log_subscription" "log_subscription" {
  resource_identifier = aws_vpclattice_service.service.id
  destination_arn     = aws_cloudwatch_log_group.log_group_lattice.arn
}

resource "aws_cloudwatch_log_group" "log_group_lattice" {
  name              = "/aws/lattice/service/service-example"
  retention_in_days = 7
}

# Lambda Target
resource "aws_vpclattice_target_group" "lambda_target" {
  name = "lambda-target"
  type = "LAMBDA"
}

resource "aws_vpclattice_target_group_attachment" "lambda_target_attachment" {
  target_group_identifier = aws_vpclattice_target_group.lambda_target.id

  target { id = aws_lambda_function.lambda_function.arn }
}

# Listeners and Rules
resource "aws_vpclattice_listener" "listener" {
  name               = "example"
  protocol           = "HTTPS"
  service_identifier = aws_vpclattice_service.service.id

  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.lambda_target.id
      }
    }
  }
}

# VPC Association (only if ingress VPC is provided)
resource "aws_vpclattice_service_network_vpc_association" "example" {
  count = local.vpc_association ? 1 : 0

  vpc_identifier             = var.ingress_vpc_id
  service_network_identifier = aws_vpclattice_service_network.service_network.id
}

# ---------- SERVICE: Lambda Function ----------
# IAM Role
resource "aws_iam_role" "role_lambda" {
  name               = "lambda_role_vpclattice_example"
  assume_role_policy = data.aws_iam_policy_document.policy_document.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "lambdabasic_iam_role_policy_attachment" {
  name       = "lambdabasic_iam_role_policy_attachment_vpclattice_example"
  roles      = [aws_iam_role.role_lambda.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
data "archive_file" "zip_python_code" {
  type        = "zip"
  source_file = "./lambda_region.py"
  output_path = "./lambda_region.zip"
}

resource "aws_cloudwatch_log_group" "log_group_lambda" {
  name              = "/aws/lambda/lattice-lambda-region"
  retention_in_days = 7
}

resource "aws_lambda_function" "lambda_function" {
  filename      = "./lambda_region.zip"
  function_name = "lattice-lambda-region"
  description   = "Obtaining the AWS Region where the function is located."
  role          = aws_iam_role.role_lambda.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 10
}

# ---------- ROUTE 53 RECORDS ----------
# Route 53 CNAME record in "Consumer" Hosted Zone
resource "aws_route53_record" "consumer_cname_record" {
  count = local.create_consumer_record ? 1 : 0

  zone_id = var.consumer_hostedzone_id
  name    = var.custom_domain_name
  type    = "CNAME"
  ttl     = 300
  records = [var.ingress_nlb_domainname]
}

# Route 53 CNAME record in "Ingress" Hosted Zone
resource "aws_route53_record" "ingress_cname_record" {
  count = local.ingress_hostedzone_id ? 1 : 0

  zone_id = var.ingress_hostedzone_id
  name    = var.custom_domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_vpclattice_service.service.dns_entry[0].domain_name]
}