# Lab Architecture

## Objective

Build a small Windows enterprise environment to practice and demonstrate
entry-level IT support, system administration, networking, Active Directory,
PowerShell, and troubleshooting skills.

## Environment

### Host
- Windows 11 Home
- 16 GB RAM
- VirtualBox

### LAB-DC01
- Windows Server 2025
- Active Directory Domain Services
- DNS
- 4 GB RAM
- 2 vCPU

### LAB-PC01
- Windows 11 Enterprise
- Domain-joined workstation
- 4 GB RAM
- 2 vCPU

## Planned Domain

`corp.lucalab.test`

## Planned Network

`10.10.10.0/24`

| Device | Hostname | IP |
|---|---|---|
| Domain Controller | LAB-DC01 | 10.10.10.10 |
| Workstation | LAB-PC01 | 10.10.10.20 |