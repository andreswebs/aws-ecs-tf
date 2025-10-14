When a development or infrastructure task is completed:

1. Review changes for correctness and adherence to code style (.editorconfig).
2. Run 'terraform plan' to verify infrastructure changes.
3. Apply changes with 'terraform apply' if plan is correct.
4. For AWS ECS changes, verify service health in AWS Console or via CLI.
5. If relevant, connect to containers using AWS CLI to validate runtime configuration.
6. Commit and push changes to version control (git).
7. If security-related, notify project maintainer as per SECURITY.md.

No automated tests or CI/CD pipeline found; please update if such processes exist.