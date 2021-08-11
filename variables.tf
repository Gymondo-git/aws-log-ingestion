variable "name" {
  type        = string
  description = "The name of the lambda function"
}

variable "policy" {
  type = object({
    json = string
  })
  description = "An additional policy to attach to the Lambda function role"
  default     = null
}

variable "enable_infra" {
  type        = string
  description = "Determines if logs are forwarded to New Relic Infrastructure"
}

variable "license_key" {
  type        = string
  description = "Your NewRelic license key"
}

variable "enable_logging" {
  type        = string
  description = "Determines if logs are forwarded to New Relic Logging"
}

variable "enable_debug_logging" {
  type        = string
  description = "A boolean to determine if you want to output debug messages in the CloudWatch console"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Determines the subnet ids for the handler"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Determines the security group ids for the handler"
}

variable "region" {
  type        = string
  description = "The region that should be used"
}

variable "account_id" {
  type        = string
  description = "The account id of this account"
}

variable "log_groups" {
  description = "The log groups that should be monitored"
  type        = any
}

variable "newrelic_api_key" {
  sensitive = true
}

variable "newrelic_account_id" {
  sensitive = true
}