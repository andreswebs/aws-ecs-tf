#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="${1}"
SERVICE_NAME="${2}"
CONTAINER_NAME="${3}"

# Get the task ARN for the smoketest task
TASK_ARN=$(
  aws ecs list-tasks \
      --cluster "${CLUSTER_NAME}" \
      --service-name "${SERVICE_NAME}" \
      --desired-status RUNNING \
      --output text \
      --query 'taskArns[0]'
)

if [[ -z "${TASK_ARN}" ]]; then
  echo "No running task found in service ${SERVICE_NAME} on cluster ${CLUSTER_NAME}" >&2
  exit 1
fi

aws ecs execute-command --cluster "${CLUSTER_NAME}" \
    --task "${TASK_ARN}" \
    --container "${CONTAINER_NAME}" \
    --interactive \
    --command "bash"
