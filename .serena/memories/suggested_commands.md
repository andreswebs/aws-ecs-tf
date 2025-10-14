# Suggested Commands

## AWS CLI
- aws ecs execute-command --cluster "${CLUSTER_NAME}" --task "${TASK_ID}" --container wireguard --interactive --command "/bin/bash"

## Terraform
- terraform init
- terraform plan
- terraform apply
- terraform destroy

## General
- cat /config/peer_<name>/peer_<name>.conf (inside container)

## Utilities (macOS/Darwin)
- git, ls, cd, grep, find, cat

# Note
No custom linting, formatting, or test commands found. Please add if available.