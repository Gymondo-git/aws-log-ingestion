module "this" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = format("%s-%s", var.name, terraform.workspace)
  description   = "Send log data from CloudWatch Logs to New Relic Infrastructure (Cloud Integrations) and New Relic Logging."
  handler       = "function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30

  source_path = format("%s/src", path.module)

  policy = var.policy

  trusted_entities = ["lambda.amazonaws.com"]

  environment = {
    variables = {
      INFRA_ENABLED         = var.enable_infra
      LICENSE_KEY           = var.license_key
      LOGGING_ENABLED       = var.enable_logging
      DEBUG_LOGGING_ENABLED = var.enable_debug_logging
      NEW_RELIC_API_KEY     = var.newrelic_api_key
      NEW_RELIC_ACCOUNT_ID  = var.newrelic_account_id
    }
  }

  vpc_config = {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_lambda_permission" "this" {
  for_each      = var.log_groups
  action        = "lambda:InvokeFunction"
  function_name = module.this.function_arn
  principal     = format("logs.%s.amazonaws.com", var.region)
  source_arn    = lookup(each.value, "arn")
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each        = var.log_groups
  name            = format("%s-lambda-subscription-%s", var.name, lookup(each.value, "name"))
  log_group_name  = lookup(each.value, "name")
  filter_pattern  = lookup(each.value, "filter_pattern")
  destination_arn = module.this.function_arn

  depends_on = [aws_lambda_permission.this]
}
