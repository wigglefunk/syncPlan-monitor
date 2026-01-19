# satellite_sync_plan_weekly_enforcement

An Ansible role to enforce weekly sync plan intervals across all organizations in Red Hat Satellite.

## Purpose

This role ensures that **all sync plans** in **all organizations** (except those explicitly opted out) have their interval set to `weekly`. This is a compliance enforcement role - it does not create or delete sync plans, only modifies the interval attribute.

## Compliance Rule

| Current Interval | Action |
|------------------|--------|
| `hourly` | Changed to `weekly` |
| `daily` | Changed to `weekly` |
| `custom cron` | Changed to `weekly` |
| `weekly` | No change (already compliant) |

**Simple logic:** If `interval != 'weekly'`, set it to `weekly`.

## What This Role Does NOT Do

- Create sync plans
- Delete sync plans
- Enable or disable sync plans
- Modify sync dates
- Modify products or repositories
- Trigger sync execution
- Change any organization metadata

## Requirements

### Ansible Collections

The `redhat.satellite` collection is required. Install it using:

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

### Credentials

The following variables must be provided at runtime (typically via AAP credentials):

| Variable | Description |
|----------|-------------|
| `satellite_setup_username` | Satellite admin username |
| `satellite_initial_admin_password` | Satellite admin password |

## Role Variables

### defaults/main.yml

| Variable | Default | Description |
|----------|---------|-------------|
| `satellite_server_url` | `https://satellite.example.com` | Full URL to your Red Hat Satellite server |
| `sync_plan_enforcement_org_opt_out` | `[]` | List of organization names to skip during enforcement |

### Example Variable Override

```yaml
# In group_vars, host_vars, or AAP survey
sync_plan_enforcement_org_opt_out:
  - "Lab_Environment"
  - "Test_Org"
  - "Development"
```

## Example Playbook

```yaml
---
# playbooks/enforce_weekly_sync_plans.yml
- name: Enforce weekly sync plan intervals across all Satellite organizations
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    # Credentials - typically injected by AAP
    satellite_setup_username: "admin"
    satellite_initial_admin_password: "{{ vault_satellite_password }}"

    # Organizations to skip
    sync_plan_enforcement_org_opt_out:
      - "Lab_Org"

  roles:
    - satellite_sync_plan_weekly_enforcement
```

## Example Output

```
TASK [satellite_sync_plan_weekly_enforcement : Display compliance report header]
ok: [localhost] => {
    "msg": "\n============================================================\nWeekly Sync Plan Interval Compliance Report\n============================================================\n"
}

TASK [satellite_sync_plan_weekly_enforcement : Display corrected organizations]
ok: [localhost] => {
    "msg": "Corrected Organizations (interval changed to weekly):\n  - Finance\n  - Engineering\n"
}

TASK [satellite_sync_plan_weekly_enforcement : Display compliant organizations]
ok: [localhost] => {
    "msg": "Compliant Organizations (no changes required):\n  - HR\n  - Operations\n"
}

TASK [satellite_sync_plan_weekly_enforcement : Display opted-out organizations]
ok: [localhost] => {
    "msg": "Opted-Out Organizations (skipped):\n  - Lab_Org\n"
}

TASK [satellite_sync_plan_weekly_enforcement : Display enforcement details]
ok: [localhost] => {
    "msg": "\nEnforcement Details:\n  - Org: Finance, Plan: Daily RHEL Sync, Was: daily, Now: weekly\n  - Org: Engineering, Plan: Hourly Updates, Was: hourly, Now: weekly\n\n============================================================\nEnd of Report\n============================================================\n"
}
```

## AAP Integration

### Job Template Setup

1. Create a new Job Template in AAP
2. Select the playbook that calls this role
3. Attach a Red Hat Satellite credential (or use extra variables for credentials)
4. Optionally, create a Survey to allow users to specify `sync_plan_enforcement_org_opt_out`

### Credential Type

If using AAP's built-in Red Hat Satellite credential type, map the fields to:
- `satellite_server_url`
- `satellite_setup_username`
- `satellite_initial_admin_password`

## Idempotency

This role is fully idempotent:
- Running it multiple times produces the same result
- If all sync plans are already set to `weekly`, no changes are made
- The compliance report accurately reflects the state after each run

## License

See organization license terms.

## Author

Generated with assistance from Claude (Anthropic).
