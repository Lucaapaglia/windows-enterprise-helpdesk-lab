# Windows Enterprise Helpdesk Lab

Hands-on Windows enterprise helpdesk lab built to demonstrate practical entry-level IT support and systems administration skills using Active Directory, DNS, Windows 11, PowerShell, networking, permissions, Group Policy, and structured troubleshooting.

## Current Implementation

The lab currently includes:

- Windows Server 2025 domain controller (`LAB-DC01`)
- Active Directory Domain Services and DNS
- Domain: `corp.lucalab.test`
- Structured OUs for users, computers, and groups
- Department security groups for Finance, HR, Sales, and IT
- Windows 11 Enterprise workstation (`LAB-PC01`)
- Domain-joined client authentication
- Static addressing on an isolated VirtualBox network
- SMB department shares with NTFS permissions
- AGDLP-style group-based resource access
- User and computer Group Policy
- Group Policy Preferences with department drive mapping
- Item-level targeting based on AD group membership
- tested PowerShell user-onboarding automation
- duplicate-account and department validation
- end-to-end onboarding verification from AD creation through file access
- real troubleshooting write-ups based on configuration issues encountered during the lab

## Lab Topology

```text
VirtualBox Internal Network: LAB-NET
Network: 10.10.10.0/24

LAB-DC01
Windows Server 2025
10.10.10.10
AD DS + DNS + SMB
      |
      | LAB-NET
      |
LAB-PC01
Windows 11 Enterprise
10.10.10.20
Domain joined
```

## Active Directory Structure

```text
corp.lucalab.test
├── Domain Controllers
│   └── LAB-DC01
└── Copenhagen
    ├── Computers
    │   └── LAB-PC01
    ├── Groups
    └── Users
        ├── Finance
        ├── HR
        ├── IT
        └── Sales
```

## Group Policy

The lab uses separate GPOs for computer and user configuration:

- `GPO-Workstation-Baseline` — linked to `Copenhagen\Computers`
- `GPO-User-Baseline` — linked to `Copenhagen\Users`
- `GPO-Department-Drive-Mapping` — linked to `Copenhagen\Users`

Department drives are mapped with Group Policy Preferences and item-level targeting:

| Group | Drive | Share |
|---|---:|---|
| `GG-Finance` | `F:` | `\\LAB-DC01\Finance` |
| `GG-HR` | `H:` | `\\LAB-DC01\HR` |
| `GG-Sales` | `S:` | `\\LAB-DC01\Sales` |
| Domain users | `P:` | `\\LAB-DC01\Public` |

## PowerShell Onboarding

[`New-LabUser.ps1`](scripts/New-LabUser.ps1) automates:

- username and UPN generation
- supported-department validation
- OU validation
- department-group validation
- duplicate-account detection
- AD user creation
- first-logon password change
- automatic `GG-Department` assignment

The workflow was tested end-to-end with a Finance account. The new user received the correct user GPOs, `F:` and `P:` drive mappings, write access to Finance, and an access-denied result against Sales.

See [User onboarding automation](docs/user-onboarding.md).

## Documentation

- [Lab architecture](docs/architecture.md)
- [Active Directory configuration](docs/active-directory.md)
- [Directory structure](docs/directory-structure.md)
- [Windows workstation domain join](docs/workstation-domain-join.md)
- [File sharing and permissions](docs/file-sharing-and-permissions.md)
- [Group Policy configuration](docs/group-policy.md)
- [User onboarding automation](docs/user-onboarding.md)

## Troubleshooting Tickets

- [Ticket 001 — Finance share access](tickets/001-finance-share-access.md)
- [Ticket 002 — Workstation inherited Domain Controller policy](tickets/002-workstation-inherited-domain-controller-policy.md)
- [Ticket 003 — User Group Policies not applying](tickets/003-user-gpo-not-applying.md)
- [Ticket 004 — Workstation GPO computer settings disabled](tickets/004-workstation-gpo-computer-settings-disabled.md)

These tickets document real configuration issues encountered during the project and the investigation used to identify their root causes.

## Skills Demonstrated

- Windows Server administration
- Active Directory users, groups, computers, and OUs
- DNS and domain discovery
- Windows domain joins and authentication
- TCP/IP configuration and troubleshooting
- SMB file sharing and NTFS permissions
- AGDLP access-control design
- Group Policy Management
- Group Policy Preferences
- item-level targeting
- RSOP and `gpresult`
- PowerShell AD automation
- input validation and duplicate checks
- Windows Security Event Log troubleshooting
- technical documentation
- root-cause analysis

## Next Stages

Planned additions include:

- employee offboarding automation
- delegated helpdesk permissions / least-privilege administration
- additional DNS and network troubleshooting scenarios
- final repository polish and network diagram

## Purpose

This repository is a practical portfolio project intended to show the configuration, verification, troubleshooting, and documentation process behind a small Windows enterprise environment rather than only listing technologies on a CV.
