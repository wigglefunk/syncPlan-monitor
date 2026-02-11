# satellite_sync_plan_weekly_enforcement

An Ansible role to enforce weekly sync plan intervals across all organizations in Red Hat Satellite, with product sync status reporting and failure email notifications.

## Purpose

This role ensures that **all sync plans** in **all organizations** (except those explicitly opted out) have their interval set to `weekly`. It also reports on the sync status of all products across all sync plans and sends an email notification if any sync failures or incomplete syncs are detected.

## Compliance Rule

| Current Interval | Action |
|------------------|--------|
| `hourly` | Changed to `weekly` |
| `daily` | Changed to `weekly` |
| `custom cron` | Changed to `weekly` |
| `weekly` | No change (already compliant) |

**Simple logic:** If `interval != 'weekly'`, set it to `weekly`.

## Product Sync Status Monitoring

In addition to interval enforcement, this role collects and reports on the sync status of every product across all sync plans in all processed organizations.

### Data Points Collected

| Field | Description |
|-------|-------------|
| `name` | Product name (e.g., "Red Hat Enterprise Linux for x86_64") |
| `sync_state` | Current sync status of the product |
| `last_sync` | Timestamp of the last completed sync |

### Sync State Evaluation

| Sync State | Result |
|------------|--------|
| `Syncing Complete.` | Healthy - no action taken |
| Anything else | Flagged as `*** SYNC FAILURE ***` |

### Email Notification

When one or more products have a `sync_state` that is **not** `Syncing Complete.`, the role sends an email alert containing the organization, sync plan, product name, sync state, and last sync timestamp for each failure.

**No failures = no email.** The role only sends mail when there is something to report.

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

The `redhat.satellite` and `community.general` collections are required. Install them using:

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
| `smtp_host` | `localhost` | SMTP server hostname or IP |
| `smtp_port` | `25` | SMTP server port (25 = plain, 587 = starttls, 465 = ssl) |
| `smtp_secure` | `try` | SMTP connection security: `try`, `always`, `never`, or `starttls` |
| `smtp_username` | *(undefined)* | SMTP auth username (optional - omit if relay needs no auth) |
| `smtp_password` | *(undefined)* | SMTP auth password (optional - omit if relay needs no auth) |
| `sync_failure_email_from` | `satellite-noreply@example.com` | Sender address for failure notification emails |
| `sync_failure_email_to` | `["satellite-admins@example.com"]` | Recipient list for failure notification emails |

### Example Variable Override

```yaml
# In group_vars, host_vars, or AAP survey
sync_plan_enforcement_org_opt_out:
  - "Lab_Environment"
  - "Test_Org"
  - "Development"

smtp_host: "smtp.corp.example.com"
smtp_port: 25
smtp_secure: "try"
sync_failure_email_from: "satellite-alerts@corp.example.com"
sync_failure_email_to:
  - "infra-team@corp.example.com"
  - "oncall@corp.example.com"
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

    # Email settings for sync failure alerts
    smtp_host: "smtp.corp.example.com"
    sync_failure_email_from: "satellite-noreply@corp.example.com"
    sync_failure_email_to:
      - "satellite-admins@corp.example.com"

  roles:
    - satellite_sync_plan_weekly_enforcement
```

### Failure Email (sent only when failures exist)

```
============================================================
Satellite Sync Failure Report
============================================================

1 product(s) with incomplete or failed sync detected.

Failures:
  *** SYNC FAILURE ***
    Organization: Engineering
    Sync Plan:    Engineering Weekly
    Product:      Red Hat Satellite Capsule
    Sync State:   Sync Incomplete
    Last Sync:    2026-01-20 04:30:16 UTC

============================================================
End of Satellite Sync Failure Report
============================================================
```

## AAP Integration

### Job Template Setup

1. Create a new Job Template in AAP
2. Select the playbook that calls this role
3. Attach a Red Hat Satellite credential (or use extra variables for credentials)
4. Optionally, create a Survey to allow users to specify `sync_plan_enforcement_org_opt_out`
5. Set SMTP and email variables via group_vars, extra_vars, or Survey as needed

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
- The sync status report reflects the current state of all products
- Email notifications are only sent when failures exist; clean runs produce no email
