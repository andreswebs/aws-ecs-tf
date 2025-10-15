# Suggested Commands

## AWS CLI

- Execute command on ECS task:
  ```sh
  aws ecs execute-command --cluster "${CLUSTER_NAME}" --task "${TASK_ID}" --container "${CONTAINER_NAME}" --interactive --command "${COMMAND}"
  ```

## Terraform

```sh
terraform init
terraform plan
terraform apply
terraform destroy
```
