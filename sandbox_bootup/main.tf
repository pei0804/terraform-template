###########
# S3 Bucket
###########
resource aws_s3_bucket sandbox {
  bucket = var.bucket_name
  acl    = "private"
}

############
# CloudTrail
############
resource aws_cloudtrail sandbox {
  name                          = "sandbox_trail"
  s3_bucket_name                = aws_s3_bucket.sandbox.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
}

############
# AWS Config
############
resource "aws_config_delivery_channel" "foo" {
  name           = "AWSConfigSandbox"
  s3_bucket_name = aws_s3_bucket.sandbox.bucket
  s3_key_prefix = "config"
  depends_on     = [aws_config_configuration_recorder.sandbox]
}

resource "aws_config_configuration_recorder" "sandbox" {
  name     = "AWSConfigSandbox"
  role_arn = aws_iam_role.sandbox.arn
}

resource "aws_iam_role" "sandbox" {
  name = "AWSConfigSandobx"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource aws_iam_role_policy sandbox {
  name = "S3FullAccess"
  role = aws_iam_role.sandbox.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.sandbox.arn}",
        "${aws_s3_bucket.sandbox.arn}/config/*"
      ]
    }
  ]
}
POLICY
}

#################
# Password Policy
#################
resource aws_iam_account_password_policy strict {
  minimum_password_length        = 64
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

########
# Budget
########
resource aws_budgets_budget cost {
  name              = "sandbox"
  budget_type       = "COST"
  limit_amount      = var.limit_usd_amount
  limit_unit        = "USD"
  time_period_start = "2020-05-10_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.email]
  }
}

###########
# GuardDuty
###########
resource aws_guardduty_detector sandbox {
  enable = true
}