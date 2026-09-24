# Lab Architecture

![Windows Enterprise Helpdesk Lab architecture](../00-lab-architecture.svg)

## Objective

Build a small Windows enterprise environment that demonstrates practical helpdesk and junior systems-administration work: identity management, endpoint policy, file access, delegated administration, PowerShell automation, and troubleshooting.

## Core systems

| System | Platform | Address | Purpose |
|---|---|---:|---|
| `LAB-DC01` | Windows Server 2025 | `10.10.10.10` | AD DS, DNS, Group Policy, SMB shares |
| `LAB-PC01` | Windows 11 Enterprise | `10.10.10.20` | Domain-joined client and validation workstation |

Both systems use the isolated VirtualBox internal network `LAB-NET` (`10.10.10.0/24`). The workstation uses `10.10.10.10` as its DNS server.

## Identity and access

The domain is `corp.lucalab.test` (NetBIOS: `CORP`). User accounts are organized below the Copenhagen OU by department, with a separate Disabled Users OU for offboarded accounts.

Department file access follows an AGDLP-style pattern:

```text
Account
  ↓
Global department group
  ↓
Domain-local resource group
  ↓
SMB / NTFS permission
```

Example:

```text
Emma Jensen
  ↓
GG-Finance
  ↓
DL-Finance-RW
  ↓
\\LAB-DC01\Finance
```

## Group Policy

Three purpose-specific GPOs are used:

- `GPO-Workstation-Baseline`
- `GPO-User-Baseline`
- `GPO-Department-Drive-Mapping`

Drive Maps uses Group Policy Preferences and item-level targeting to map Finance, HR, Sales, and Public shares.

## Delegated administration

`alex.helpdesk` is a normal IT user and a member of `GG-Helpdesk-Admins`, not Domain Admins. Scoped delegation allows routine user lifecycle work without broad domain-administrator rights.

The lifecycle scripts support explicit delegated credentials, domain-controller targeting, `-WhatIf`, confirmation controls, and verification.

## Troubleshooting validation

The workstation was intentionally configured with an incorrect DNS server (`10.10.10.99`). IP connectivity to the server remained available while name resolution and Group Policy failed. Restoring DNS to `10.10.10.10` and clearing the DNS cache restored domain-dependent functionality and a healthy secure channel.
