module "this" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = format("%s-%s", var.name, terraform.workspace)
  description   = "Send log data from CloudWatch Logs to New Relic Infrastructure (Cloud Integrations) and New Relic Logging."

  runtime = "python3.11"
  handler = "function.lambda_handler"

  publish = true

  timeout = 30

  environment_variables = {
    INFRA_ENABLED         = var.enable_infra
    LICENSE_KEY           = var.license_key
    LOGGING_ENABLED       = var.enable_logging
    DEBUG_LOGGING_ENABLED = var.enable_debug_logging
    NEW_RELIC_API_KEY     = var.newrelic_api_key
    NEW_RELIC_ACCOUNT_ID  = var.newrelic_account_id
  }

  create_role = true

  source_path = format("%s/src", path.module)

  trusted_entities = ["lambda.amazonaws.com"]

  attach_network_policy  = true
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_lambda_permission" "this" {
  for_each      = var.log_group_permission_arns
  action        = "lambda:InvokeFunction"
  function_name = module.this.lambda_function_arn
  principal     = format("logs.%s.amazonaws.com", var.region)
  source_arn    = format("%s", each.value)
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each        = var.log_groups
  name            = format("%s-lambda-subscription-%s", var.name, lookup(each.value, "name"))
  log_group_name  = lookup(each.value, "name")
  filter_pattern  = lookup(each.value, "filter_pattern")
  destination_arn = module.this.lambda_function_arn

  depends_on = [aws_lambda_permission.this]
}
