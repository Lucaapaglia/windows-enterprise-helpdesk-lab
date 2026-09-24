# Windows Enterprise Helpdesk Lab

Hands-on Windows enterprise helpdesk lab built to demonstrate practical entry-level IT support and systems administration skills using Active Directory, DNS, Windows 11, PowerShell, networking, permissions, Group Policy, least-privilege administration, and structured troubleshooting.

## Current Implementation

The lab currently includes:

- Windows Server 2025 domain controller (`LAB-DC01`)
- Active Directory Domain Services and DNS
- Domain: `corp.lucalab.test`
- Structured OUs for users, computers, groups, and disabled accounts
- Department security groups for Finance, HR, Sales, and IT
- Windows 11 Enterprise workstation (`LAB-PC01`)
- Domain-joined client authentication
- Static addressing on an isolated VirtualBox network
- SMB department shares with NTFS permissions
- AGDLP-style group-based resource access
- user and computer Group Policy
- Group Policy Preferences with department drive mapping
- item-level targeting based on AD group membership
- PowerShell onboarding and offboarding automation
- delegated helpdesk administration with scoped AD permissions
- explicit credential and domain-controller targeting
- `-WhatIf` and confirmation-based safety controls
- protected-account checks during offboarding
- end-to-end lifecycle verification without Domain Admin
- real troubleshooting write-ups based on issues encountered during the lab

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
        ├── Disabled Users
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

## PowerShell Automation

[`New-LabUser.ps1`](scripts/New-LabUser.ps1) automates employee provisioning:

- username and UPN generation
- supported-department validation
- OU and department-group validation
- duplicate-account detection
- AD user creation
- first-logon password change
- automatic department-group assignment
- final account and membership verification

[`Disable-LabUser.ps1`](scripts/Disable-LabUser.ps1) automates employee offboarding:

- account and group inspection
- privileged-account protection
- account disablement
- explicit group-membership removal
- movement to the `Disabled Users` OU
- offboarding-date documentation
- final state verification

Both scripts support delegated `-Credential`, explicit `-Server`, and `-WhatIf` execution.

A full Sales lifecycle was tested using the delegated `alex.helpdesk` credential. The onboarding preview made no changes; the real run created `maja.nielsen` in Sales and assigned `GG-Sales`. The offboarding preview also made no changes; the confirmed real run disabled the account, removed `GG-Sales`, moved it to `Disabled Users`, and recorded the offboarding date.

## Delegated Helpdesk Administration

A dedicated `GG-Helpdesk-Admins` group is used for scoped user-management permissions.

The test operator `alex.helpdesk` remained outside Domain Admins, Enterprise Admins, and Administrators while successfully completing onboarding and offboarding work with delegated permissions.

This demonstrates a more realistic support model than using broad domain-administrator access for routine user lifecycle tasks.

## Documentation

- [Lab architecture](docs/architecture.md)
- [Active Directory configuration](docs/active-directory.md)
- [Directory structure](docs/directory-structure.md)
- [Windows workstation domain join](docs/workstation-domain-join.md)
- [File sharing and permissions](docs/file-sharing-and-permissions.md)
- [Group Policy configuration](docs/group-policy.md)
- [User onboarding automation](docs/user-onboarding.md)
- [User offboarding automation](docs/user-offboarding.md)
- [Delegated helpdesk administration](docs/delegated-helpdesk-administration.md)
- [PowerShell automation safety](docs/powershell-automation-safety.md)

## Troubleshooting Tickets

- [Ticket 001 — Finance share access](tickets/001-finance-share-access.md)
- [Ticket 002 — Workstation inherited Domain Controller policy](tickets/002-workstation-inherited-domain-controller-policy.md)
- [Ticket 003 — User Group Policies not applying](tickets/003-user-gpo-not-applying.md)
- [Ticket 004 — Workstation GPO computer settings disabled](tickets/004-workstation-gpo-computer-settings-disabled.md)

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
- delegated least-privilege administration
- `SupportsShouldProcess`, `-WhatIf`, and confirmations
- credential handling and explicit server targeting
- protected-account safeguards
- Windows Security Event Log troubleshooting
- technical documentation
- root-cause analysis

## Next Stages

Planned additions include:

- one focused DNS/network troubleshooting scenario
- final repository polish and network diagram

## Purpose

This repository is a practical portfolio project intended to show the configuration, verification, troubleshooting, and documentation process behind a small Windows enterprise environment rather than only listing technologies on a CV.
