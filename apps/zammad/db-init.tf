module "lambda_base_dbinit" {
  count   = var.dbinit_enabled ? 1 : 0
  source  = "andreswebs/lambda-base/aws"
  version = "0.7.0"
  name    = "${var.name}-dbinit"
}

module "iam_policy_document_dbinit_secret_access" {
  count        = var.dbinit_enabled ? 1 : 0
  source       = "andreswebs/secrets-access-policy-document/aws"
  version      = "1.7.0"
  secret_names = [aws_secretsmanager_secret.db.name]
}

resource "aws_iam_role_policy" "dbinit" {
  count  = var.dbinit_enabled ? 1 : 0
  policy = module.iam_policy_document_dbinit_secret_access[0].json
  role   = module.lambda_base_dbinit[0].iam_role.id
}

module "lambda_dbinit" {
  count   = var.dbinit_enabled ? 1 : 0
  source  = "andreswebs/lambda/aws"
  version = "0.0.2"

  depends_on = [aws_iam_role_policy.dbinit]

  name      = "${var.name}-dbinit"
  image_uri = var.dbinit_lambda_image_uri

  iam_role_arn   = module.lambda_base_dbinit[0].iam_role.arn
  log_group_name = module.lambda_base_dbinit[0].log_group.name

  lambda_env = {
    DB_MIGRATION_SECRET = aws_secretsmanager_secret.db.arn
    DB_MIGRATION_ROLE   = "zammad_app"
    DB_SCHEMA           = "zammad_data"
  }
}
