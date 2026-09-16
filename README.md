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
- Initial PowerShell user-provisioning script

## Lab Topology

```text
VirtualBox Internal Network: LAB-NET
Network: 10.10.10.0/24

LAB-DC01
Windows Server 2025
10.10.10.10
AD DS + DNS
      |
      |
LAB-PC01
Windows 11 Enterprise
10.10.10.20
Domain joined
```

## Documentation

- [Lab architecture](docs/architecture.md)
- [Active Directory configuration](docs/active-directory.md)
- [Directory structure](docs/directory-structure.md)
- [Workstation domain join](docs/workstation-domain-join.md)

## PowerShell

Current automation:

- [`New-LabUser.ps1`](scripts/New-LabUser.ps1) — creates a domain user in the appropriate departmental OU.

The script will be expanded as the lab progresses to cover validation, group assignment, onboarding, and offboarding workflows.

## Skills Demonstrated

- Windows Server administration
- Active Directory users, groups, and OUs
- DNS and domain discovery
- Windows domain joins and authentication
- TCP/IP configuration and troubleshooting
- PowerShell administration
- Technical documentation

## Next Stages

Planned additions include:

- SMB department shares and NTFS permissions
- AGDLP-style group-based resource access
- Group Policy configuration and troubleshooting
- Automated user onboarding and offboarding
- Helpdesk incident write-ups
- Network and authentication troubleshooting scenarios

## Purpose

This repository is a practical portfolio project intended to show the configuration, verification, troubleshooting, and documentation process behind a small Windows enterprise environment rather than only listing technologies on a CV.
