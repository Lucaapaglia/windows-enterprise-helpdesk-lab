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
- User and computer Group Policy
- Group Policy Preferences with department drive mapping
- Item-level targeting based on AD group membership
- tested PowerShell user-onboarding automation
- tested PowerShell user-offboarding automation
- delegated helpdesk administration with scoped AD permissions
- end-to-end onboarding and offboarding verification without Domain Admin
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

[`New-LabUser.ps1`](scripts/New-LabUser.ps1) automates:

- username and UPN generation
- supported-department validation
- OU and department-group validation
- duplicate-account detection
- AD user creation
- first-logon password change
- automatic `GG-Department` assignment

[`Disable-LabUser.ps1`](scripts/Disable-LabUser.ps1) automates:

- account lookup
- account disablement
- removal of explicit group memberships
- movement to the `Disabled Users` OU
- offboarding-date documentation

The onboarding workflow was tested end-to-end with a Finance user. The account received the correct GPOs and drive mappings, could write to Finance, and was denied Sales access.

The same test account was then offboarded. It was disabled, removed from `GG-Finance`, moved to `Disabled Users`, and a fresh workstation sign-in was rejected as expected.

## Delegated Helpdesk Administration

A dedicated `GG-Helpdesk-Admins` group is used for scoped user-management permissions.

The test operator `alex.helpdesk` remained outside Domain Admins, Enterprise Admins, and Administrators while successfully:

- creating `nora.larsen` in the HR OU
- adding the account to `GG-HR`
- disabling the account
- removing `GG-HR`
- moving the account to `Disabled Users`
- updating the offboarding description

This verifies that routine user lifecycle work can be completed with delegated permissions instead of broad domain-administrator access.

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
- user lifecycle management
- delegated least-privilege administration
- input validation and duplicate checks
- Windows Security Event Log troubleshooting
- technical documentation
- root-cause analysis

## Next Stages

Planned additions include:

- improved script safety and `-WhatIf` support
- additional DNS and network troubleshooting scenarios
- final repository polish and network diagram

## Purpose

This repository is a practical portfolio project intended to show the configuration, verification, troubleshooting, and documentation process behind a small Windows enterprise environment rather than only listing technologies on a CV.
