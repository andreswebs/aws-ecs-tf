module "lambda_base_dbinit" {
  count   = var.dbinit_enabled ? 1 : 0
  source  = "andreswebs/lambda-base/aws"
  version = "0.8.0"
  name    = "${var.name}-dbinit"

  vpc_permissions_enabled = true

  tags = var.tags
}

module "iam_policy_document_dbinit_secret_access" {
  count   = var.dbinit_enabled ? 1 : 0
  source  = "andreswebs/secrets-access-policy-document/aws"
  version = "1.8.0"
  secret_names = compact([
    local.db_master_secret_name,
    aws_secretsmanager_secret.db.name
  ])
}

resource "aws_iam_role_policy" "dbinit" {
  count  = var.dbinit_enabled ? 1 : 0
  policy = module.iam_policy_document_dbinit_secret_access[0].json
  role   = module.lambda_base_dbinit[0].iam_role.id
}

module "lambda_dbinit" {
  count   = var.dbinit_enabled ? 1 : 0
  source  = "andreswebs/lambda/aws"
  version = "0.0.3"

  depends_on = [aws_iam_role_policy.dbinit, module.db]

  name      = "${var.name}-dbinit"
  image_uri = var.dbinit_lambda_image_uri

  iam_role_arn   = module.lambda_base_dbinit[0].iam_role.arn
  log_group_name = module.lambda_base_dbinit[0].log_group.name

  security_group_ids = [aws_security_group.backend.id]
  subnet_ids         = var.private_subnet_ids

  lambda_env = local.dbinit_env

  tags = var.tags
}

resource "aws_lambda_invocation" "dbinit" {
  count         = var.dbinit_enabled ? 1 : 0
  depends_on    = [module.lambda_dbinit]
  function_name = module.lambda_dbinit[0].function.function_name
  qualifier     = module.lambda_dbinit[0].alias.name
  input         = jsonencode({})
}
