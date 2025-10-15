# https://developer.hashicorp.com/terraform/language/tests

run "ssm_parameters_prefix_norm" {

  command = plan

  variables {
    ssm_parameters_prefix = "///test///"
  }

  assert {
    condition     = local.ssm_parameters_prefix_norm == "/test"
    error_message = "wanted /test, got ${local.ssm_parameters_prefix_norm}"
  }

}
