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
- Initial PowerShell user-provisioning script
- Real troubleshooting write-ups based on configuration issues encountered during the lab

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

## Documentation

- [Lab architecture](docs/architecture.md)
- [Active Directory configuration](docs/active-directory.md)
- [Directory structure](docs/directory-structure.md)
- [Windows workstation domain join](docs/workstation-domain-join.md)
- [File sharing and permissions](docs/file-sharing-and-permissions.md)
- [Group Policy configuration](docs/group-policy.md)

## Troubleshooting Tickets

- [Ticket 002 — Workstation inherited Domain Controller policy](tickets/002-workstation-inherited-domain-controller-policy.md)
- [Ticket 003 — User Group Policies not applying](tickets/003-user-gpo-not-applying.md)

These tickets document real configuration issues encountered during the project and the investigation used to identify their root causes.

## PowerShell

Current automation:

- [`New-LabUser.ps1`](scripts/New-LabUser.ps1) — creates a domain user in the appropriate departmental OU.

The next automation stage will expand this into a more complete onboarding workflow with department validation, duplicate detection, automatic group assignment, and a corresponding offboarding script.

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
- Item-level targeting
- RSOP and `gpresult`
- Windows Security Event Log troubleshooting
- PowerShell administration
- Technical documentation
- Root-cause analysis

## Next Stages

Planned additions include:

- improved PowerShell onboarding automation
- employee offboarding automation
- additional helpdesk incident write-ups
- DNS and network troubleshooting scenarios
- final repository polish and network diagram

## Purpose

This repository is a practical portfolio project intended to show the configuration, verification, troubleshooting, and documentation process behind a small Windows enterprise environment rather than only listing technologies on a CV.
