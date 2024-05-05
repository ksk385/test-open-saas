provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["373010202891"]
}

data "aws_iam_policy_document" "ssm_access_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "apprunner_access_role" {
  name = "apprunner-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "build.apprunner.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "apprunner_instance_role" {
  name = "apprunner-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "tasks.apprunner.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_access_attachment" {
  role       = aws_iam_role.apprunner_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_access_attachment" {
  role       = aws_iam_role.apprunner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_service" "my_apprunner_service" {
  service_name = "test-open-saas"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access_role.arn
    }

    image_repository {
      image_configuration {
        port = "80"
        runtime_environment_secrets = {

          "DATABASE_URL" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/DATABASE_URL",

          "STRIPE_KEY"                  = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/STRIPE_KEY",
          "HOBBY_SUBSCRIPTION_PRICE_ID" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/HOBBY_SUBSCRIPTION_PRICE_ID",
          "PRO_SUBSCRIPTION_PRICE_ID"   = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/PRO_SUBSCRIPTION_PRICE_ID",
          "STRIPE_WEBHOOK_SECRET"       = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/STRIPE_WEBHOOK_SECRET",

          "ADMIN_EMAILS" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/ADMIN_EMAILS",

          "GOOGLE_CLIENT_ID"     = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/GOOGLE_CLIENT_ID",
          "GOOGLE_CLIENT_SECRET" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/GOOGLE_CLIENT_SECRET",

          "SENDGRID_API_KEY" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/SENDGRID_API_KEY",

          "GOOGLE_ANALYTICS_CLIENT_EMAIL" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/GOOGLE_ANALYTICS_CLIENT_EMAIL",
          "GOOGLE_ANALYTICS_PRIVATE_KEY"  = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/GOOGLE_ANALYTICS_PRIVATE_KEY",
          "GOOGLE_ANALYTICS_PROPERTY_ID"  = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/GOOGLE_ANALYTICS_PROPERTY_ID",

          "AWS_S3_IAM_ACCESS_KEY" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/AWS_S3_IAM_ACCESS_KEY",
          "AWS_S3_IAM_SECRET_KEY" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/AWS_S3_IAM_SECRET_KEY",
          "AWS_S3_FILES_BUCKET"   = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/AWS_S3_FILES_BUCKET",
          "AWS_S3_REGION"         = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/AWS_S3_REGION",

          "WASP_SERVER_URL"     = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/WASP_SERVER_URL",
          "WASP_WEB_CLIENT_URL" = "arn:aws:ssm:us-east-1:373010202891:parameter/opensaas/prod/WASP_WEB_CLIENT_URL"
        }
      }
      image_identifier      = "373010202891.dkr.ecr.us-east-1.amazonaws.com/test-open-saas:latest"
      image_repository_type = "ECR"

    }
    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = "1 vCPU"
    memory            = "2 GB"
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }

  tags = {
    Environment = "Production"
  }
}
