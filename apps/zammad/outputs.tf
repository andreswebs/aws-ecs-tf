output "dbinit" {
  value = merge(
    try(module.lambda_base_dbinit[0], {}),
    try(module.lambda_dbinit[0], {}),
  )
}
