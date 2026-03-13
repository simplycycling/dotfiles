---
description: Write or review an Ansible playbook
allowed-tools: Write, Read
argument-hint: [describe the task, or paste an existing playbook to review]
---

Write or review an Ansible playbook for: $ARGUMENTS

Context:
- Environment: fintech, AWS-primary (some Azure), EKS/Kubernetes
- Use cases: EC2/bastion OS configuration, post-provisioning tasks, OS hardening, RDS schema migration tooling, K8s app deployment where Helm is not appropriate
- Secrets management: Azure DevOps variable groups (injected as env vars); ansible-vault for secrets in the repo
- CI/CD: Azure DevOps pipelines

---

**When writing a new playbook:**

1. Follow role-based directory structure where the logic is reusable (`roles/role-name/tasks/main.yml`, `handlers/main.yml`, `defaults/main.yml`, `templates/`). Use a flat playbook only for one-off tasks.
2. Reference all secrets via ansible-vault (`{{ vault_secret_name }}`). Never include plaintext passwords, API keys, or tokens.
3. Tag every task for selective execution — use at minimum `[install]`, `[configure]`, `[harden]` categories as appropriate.
4. Every `shell` or `command` module task must have `changed_when` defined. If the task is purely informational, use `changed_when: false`. If it makes a change, detect the change condition explicitly.
5. Use `block/rescue/always` for tasks that require rollback or cleanup on failure.
6. Apply `become: yes` only where root privileges are genuinely required — not as a blanket default on the play.
7. Include a `requirements.yml` listing any community collections used (e.g., `community.kubernetes`, `community.postgresql`, `community.general`).
8. Use `notify` and handlers for service restarts — never restart services inline in tasks.
9. Use `ansible.builtin.*` FQCN for all core module calls to avoid ambiguity.

**When reviewing an existing playbook:**

Check and report on:
- Hardcoded secrets, credentials, or IP addresses
- Non-idempotent tasks (`shell`/`command` without `changed_when`, `creates`, or `removes`)
- Missing error handling (`ignore_errors: yes` used broadly, no `block/rescue`)
- Deprecated modules (e.g., `yum` vs `ansible.builtin.dnf`, `include` vs `ansible.builtin.include_tasks`)
- Overly broad `become: yes` usage
- Missing tags
- Tasks that could be replaced by a purpose-built module
- Hardcoded environment-specific values that should be variables

Output a review with findings grouped by severity (Critical / Warning / Info) and specific line-level recommendations.

---

After generating or reviewing, offer to save as playbook files.
