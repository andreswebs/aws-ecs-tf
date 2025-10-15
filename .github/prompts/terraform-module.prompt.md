## Terraform Module Scaffolding Generator

Purpose: Convert an approved Component Definition Document into a Terraform module skeleton with predictable, auditable mapping rules.

Generated Files (minimum set):

1. `modules/<component_name>/main.tf`
2. `modules/<component_name>/variables.tf`
3. `modules/<component_name>/outputs.tf`
4. `modules/<component_name>/README.md`
5. (Optional) `modules/<component_name>/locals.tf` when >3 derived values exist
6. (Optional) `modules/<component_name>/providers.tf` only if provider aliasing or version constraints are required

Mapping Rules:

- Internal Resource Record → stub `resource "<type>" "<logical_name>" {}` where `<logical_name>` = snake_case name. Avoid collisions by appending numeric index if repeated. Use "this" as the logical name if there is only one resource of this type in the module.
- External Dependency Record Outputs → corresponding input variables. Each listed attribute becomes a variable named `<external_short>*<attribute>`(e.g.`vpc*id`, `ecs_cluster_arn`).
- Inputs list of Internal Resource Record → merge into variable declarations if not sourced from external outputs or static derivations. Variables named exactly as Terraform argument where possible; if ambiguous, prefix with resource short (e.g. `task_cpu`).
- Outputs list of Internal Resource Record → module outputs named `<resource name>` unless attribute already unique globally (e.g. a single `endpoint` → `endpoint`). Prefer to output the full resource as the output value. For example output `value = aws_security_group.this`
- Provider Aliases (if annotated) → add `provider = aws.<alias>` inside resource stub and create / update `providers.tf` with `provider "aws" { alias = "<alias>" ... }` skeleton (user must fill credentials/region).

Variable Derivation Heuristics:

1. If attribute appears in >=2 Internal resource Inputs, promote to shared variable (e.g. `tags`, `environment`).
2. Tagging: Always create `variable "tags" { type = map(string) }` if any resource supports tags.
3. Common networking: if multiple resources need `subnet_ids` or `security_group_ids`, centralize variable.
4. For booleans defaulting false, set explicit default in `variables.tf` (avoid implicit). For strings with mandatory value, omit default.
5. Use `nullable = false` only when absence breaks plan (critical inputs).

Locals Generation (when needed):

- Create locals for computed names (e.g. `local.name_prefix = var.name_prefix != null ? var.name_prefix : var.component_name`).
- Derive JSON policy documents? Leave placeholder comment rather than generating content.

README.md Template Sections:

1. Title + short description (from component name and initial user description if available)
2. Inputs table (variable name, type, default, description placeholder)
3. Outputs table (output name, description placeholder)
4. External Dependencies summary (resource type + attributes consumed)
5. Example usage stub

Example Resource Stub (generated inside main.tf):

```
resource "aws_iam_role" "this" {
   name               = var.role_name != null ? var.role_name : "${var.component_name}-role"
   assume_role_policy = var.assume_role_policy
   tags               = var.tags
}
```

Generation Steps:

1. Parse document records into structured objects.
2. Build symbol tables: external attributes → input vars; internal outputs → module outputs; internal inputs → candidate variables.
3. Normalize names, detect collisions, apply suffix/index strategy.
4. Emit files in stated order; ensure deterministic ordering to keep diffs stable.
5. Present scaffolding diff for user review; wait for explicit approval before suggesting further enrichment.

Post-Generation Validation:

- `terraform validate` must succeed (agent may need to ask user to run if execution environment unavailable).
- No unused variables (flag any variable not referenced in main.tf).
- At least one output defined if internal Outputs list non-empty.

Non-Goals:

- Do not auto-generate complex IAM policies, ECS task JSON, or large listener rule blocks — place `# TODO` markers.
- Do not infer data sources beyond obvious (e.g. `data "aws_vpc"` if only `vpc_id` passed — skip unless needed for computed attributes).

User Review Prompt Example:

"Scaffolding generated for `<component_name>`. Review placeholders (TODO) for policies, container definitions, and advanced listener rules. Approve to finalize or list adjustments."

If user approves: mark Phase 3 complete and optionally propose next actions: writing actual resource arguments, adding tests (e.g. terraform compliance or policy checks), cost estimation.
