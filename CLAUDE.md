# CLAUDE.md

## Project purpose
Sample cloud-deployment templates for VyOS instances. Provides ready-to-use AWS CloudFormation stacks and Terraform/Terraform Cloud configurations for deploying VyOS routers in AWS and vSphere environments.

## Tech stack
- HashiCorp HCL (Terraform) + AWS CloudFormation YAML.
- No build system — assets are consumed directly by `terraform`/`aws cloudformation` clients.

## Build / test / run
No build. Usage examples:
```
# CloudFormation
aws cloudformation deploy --template-file CloudFormation/<flavor>/<file>.yml --stack-name <name>
# Terraform
cd Terraform/<scenario> && terraform init && terraform apply
```
Each subdirectory carries its own `readme.md` with parameters and post-deployment config.

## Repository layout
- `CloudFormation/` — AWS CloudFormation templates (basic and advanced single-instance configurations).
- `Terraform/` — Terraform configurations (e.g. `Cloud-to-Cloud/`).
- `TerraformCloud/` — Terraform Cloud + vSphere + Ansible reference deployment.
- `README.md` — placeholder.

## Cross-repo context
End-user-facing documentation samples. Independent of the build pipeline (`vyos-build`, `vyos-1x`, etc.) — these templates consume already-built VyOS images (typically from cloud marketplaces or the nightly/release artifacts published by `vyos/vyos-nightly-build`). Companion to `vyos/vyos-documentation` for cloud-deployment guidance.

## Conventions
- Commit/PR title: `component: T12345: description` (Phorge task ID at https://vyos.dev) — enforced by inherited `vyos/.github` reusable workflows where applicable.
- Only workflow currently present: `cla-check.yml` (CLA gate via `vyos/vyos-cla-signatures`).

## Mirror relationship
Mirror twin: `VyOS-Networks/vyos-automation`. Mirror pipeline not confirmed live; canonical edits happen on the `vyos/*` side.

## Notes for future contributors
- Each template ships with example post-deployment VyOS config text files. Keep these in sync when interface naming or default-config conventions change in `vyos-1x`.
- No CI runs Terraform validation — when adding HCL, run `terraform fmt -recursive` and `terraform validate` locally before pushing.
- Public-facing repo: don't embed AWS account IDs, real customer keys, or non-RFC-5737 IPv4 / non-RFC-3849 IPv6 ranges in examples.
