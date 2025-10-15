# Terraform Component Definition Instructions

Purpose: Enable an AI agent to collaboratively define a new Terraform infrastructure component in a repeatable, auditable way. The agent will create and iteratively refine a definition document capturing required resource types, external dependencies, their inputs/outputs, and documentation links — before any code is written.

## Interaction Contract

1. Always begin by asking the user for the intended component name and where to store the definition document (path + filename). If the user defers, propose a sensible default (e.g. `design/<component-name>.definition.md`). Do not proceed until the storage path is confirmed.
2. The agent maintains a single "definition document" whose content evolves across two phases: Hypotheses and Research.
3. Before entering Phase 2, obtain explicit user approval of the Phase 1 hypotheses; pause and request confirmation. Do not silently proceed.
4. Keep all resource entries as sets of Markdown paragraphs (blank line separated). Never use Markdown list markers (`-`, `*`, `1.`) for resource records. Use the sequence of three dashes (`---`) to separate records.
5. All records MUST follow the exact schemas below — no extra prose inside the record blocks.
6. Ask only targeted clarification questions; avoid broad or unfocused questioning.
7. If the user updates prior decisions, reconcile and clearly mark changed records.

## Definitions

Component: A Terraform-managed unit of infrastructure produced as one module, or a cohesive group of resources deployed together.

Internal Resource: A Terraform resource the component will provision.

External Dependency: A Terraform resource assumed to exist (prerequisite) and not created here; its exported attributes become inputs.

Component Definition Document: A structured markdown artifact produced in Phases 1–2 that lists internal resources and external dependencies using the prescribed paragraph schemas, including validated Inputs, Outputs, documentation URLs, and any pending clarifications. It is the single source of truth that drives automated scaffolding; every generated Terraform element must trace back to one record in this document.

## Phase 1: Hypotheses

Goal: Draft exhaustive lists of internal resources and external dependencies, plus hypothesized inputs/outputs, based solely on the user’s description and reasonable inference.

Steps:

1. Parse the user’s description. Extract explicit resource types (e.g. `aws_iam_role`, `aws_lb`, `aws_ecs_cluster`). Infer implied backing resources (e.g. security groups, IAM roles, execution roles, task definitions, log groups, load balancer target groups, CloudWatch log groups, service discovery, etc.). Add them even if not mentioned.
2. Create Internal Resources section. Each record format (one paragraph):

```
---

% <terraform resource type> %

---
```

3. Create External Dependencies section. For each prerequisite resource assumed to exist (e.g. VPC, subnets, shared ECS cluster, KMS keys), include required attributes needed by internal resources. Each record format (three paragraphs, blank line separated):

```
---

External

% <terraform resource type> %

Outputs: % <comma-separated attributes consumed as inputs, e.g. id, arn, name> %

---
```

4. Identify preliminary outputs that internal resources will expose for consumer modules (e.g. role ARNs, endpoint URLs, security group IDs). These will later be refined; list them inline with the internal resource in Phase 2 only — do not add now.
5. Present the document with two clearly labeled sections:
   - Description
   - Internal Resources
   - External Dependencies
6. Ask the user: "Approve Phase 1 or provide corrections?" If corrections are provided, update and re-present.

Validation Heuristics for Phase 1 (apply silently, mention issues if found):

- Does every AWS service implied by the component have required IAM roles/policies?
- Are networking primitives (VPC, subnets, security groups, load balancer listeners/target groups) considered?
- Are logging/monitoring resources (log groups, metric alarms) needed?
- Are encryption/KMS requirements present?
- Are tagging/metadata strategies required? (If yes, note they will be handled by variables later.)
- Are any resources out of scope / likely external? Reclassify if needed.

## Phase 2: Research

Goal: Replace hypotheses with validated resource specs from official Terraform Registry documentation.

Steps:

1. For every internal resource and external dependency record, locate the official Terraform Registry page. For provider AWS resources use pattern: `https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/<resource-name>` (verify existence). If missing or deprecated, flag to user.
2. Update each internal resource record to (four paragraphs, blank line separated)::

```
---

% <terraform resource type> %

% <documentation URL> %

Inputs: % <comma-separated arguments required to create> %

Outputs: % <comma-separated attributes exposed and referenced by other resources or as module outputs> %

---
```

3. Update each external dependency record to (four paragraphs, blank line separated):

```
---

External

% <terraform resource type> %

% <documentation URL> %

Outputs: % <comma-separated attributes consumed> %

---
```

4. Inputs: Include only arguments likely to be explicitly set (omit those using provider defaults unless critical). Group related fields mentally but keep flat comma-separated list. Make sure that the Inputs list contains only the REQUIRED arguments for each resource. Do NOT INVENT attributes. Make sure all the values in the Inputs list have been researched on the official page in the documentation. If uncertain, mark with a leading `?` (e.g. `?arn`) and request user clarification.
5. Outputs: Include only attributes used by other resources or exported from the module. If uncertain, mark with a leading `?` (e.g. `?arn`) and request user clarification.
6. Cross-reference: Ensure every referenced output attribute of an external dependency is present in at least one internal resource’s Inputs list.
7. Add a "Pending Clarifications" section if any `?` remain after first pass.
8. Present Phase 2 document. Ask for confirmation or adjustments.

## Record Ordering Rules

- Internal resources: Start with foundational (network, IAM, storage) then higher-level (compute, orchestration, observability) then integration (ALB/NLB, DNS, monitoring).
- External dependencies: Order by dependency resolution sequence (network, security, shared services, encryption, observability).
- Keep ordering stable across revisions; if reordering occurs due to new additions, note it in a brief change log section.

## Change Log (Optional Section)

Maintain after Phase 1 approval. Each entry one line: `Revision <n>: <summary of changes>`.

## Error Handling & Edge Cases

- If a resource name seems ambiguous: propose 2–3 candidates and ask user to choose.
- If required external dependencies seem undocumented in user context: ask user whether to include them or assume creation later.
- If a resource is provider-aliased (multiple AWS accounts/regions): annotate record with `Provider: <alias>`.
- If multi-region or multi-AZ requirements are implied, ask for count and list in Inputs (e.g. `availability_zones`).

## Quality Gates Prior to Completion

Before declaring the definition finished, silently validate:

- No record missing documentation URL in Phase 2.
- All Inputs have plausible attribute names (match Terraform docs exactly; use snake_case).
- No dangling `?` markers.
- Cross-reference consistency: each internal output referenced somewhere logically.

## Output Format Summary (Cheat Sheet)

Internal Phase 1:

```
---

aws_iam_role

---
```

Internal Phase 2:

```
---

aws_iam_role

<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role>

Inputs: name, assume_role_policy, tags

Outputs: arn, name

---
```

External Phase 1:

```
---

External

aws_vpc

Outputs: id

---
```

External Phase 2:

```
---

External

aws_vpc

<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc>

Outputs: id, cidr_block

---
```

## Interaction Pacing

- Never batch more than ~25 resources without summarizing and asking if user wants to continue or narrow scope.
- If user adds new resource mid Phase 2, create its Phase 1 record first (marked `NEW`), then research.

## Finalization

On user approval of Phase 2:

- Review the document and add the Description section to the top - base it on the original description, but improve it based on the results of Phase 2.
- Output final document plus a concise summary list of internal outputs intended for module `outputs.tf`.

## Prohibited

- Do not convert paragraphs into bullet/numbered lists.
- Do not invent provider resource names; always verify pattern.
- Do not omit pause before Phase 2.

## Example Flow (Abbreviated)

1. User: "Need Fargate service behind ALB".
2. Phase 1 Internal: `aws_ecs_task_definition`, `aws_ecs_service`, `aws_lb`, `aws_lb_target_group`, `aws_lb_listener`, `aws_iam_role`, `aws_cloudwatch_log_group`, `aws_security_group`.
3. Phase 1 External: VPC (id), Subnets (ids), ECS Cluster (arn), Route53 Hosted Zone (zone_id).
4. Phase 2: Add docs, refine Inputs/Outputs.
5. Finalize.

End of instructions.
