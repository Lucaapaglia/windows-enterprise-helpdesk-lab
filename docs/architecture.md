# Lab Architecture

## Objective

Build a small Windows enterprise environment to practice and demonstrate entry-level IT support, system administration, networking, Active Directory, PowerShell, and troubleshooting skills.

## Environment

### Host

- Windows 11 Home
- 16 GB RAM
- Oracle VirtualBox

### LAB-DC01

- Windows Server 2025
- Active Directory Domain Services
- DNS Server
- 4 GB RAM
- 2 vCPU
- Static IPv4: `10.10.10.10/24`

### LAB-PC01

- Windows 11 Enterprise
- Domain-joined workstation
- 4 GB RAM
- 3 vCPU
- Static IPv4: `10.10.10.20/24`
- DNS server: `10.10.10.10`

`LAB-PC01` uses 3 vCPUs because the host environment produced a VirtualBox UEFI black-screen issue when the VM was configured with 2 vCPUs.

## Domain

- DNS domain: `corp.lucalab.test`
- NetBIOS domain: `CORP`
- Domain controller: `LAB-DC01`

## Network

The VMs communicate through an isolated VirtualBox internal network named `LAB-NET`.

```text
Network: 10.10.10.0/24

LAB-DC01
10.10.10.10
AD DS + DNS
      |
      | LAB-NET
      |
LAB-PC01
10.10.10.20
Windows 11 Enterprise
```

| Role | Hostname | IPv4 | DNS |
|---|---|---:|---:|
| Domain Controller | `LAB-DC01` | `10.10.10.10` | `10.10.10.10` |
| Workstation | `LAB-PC01` | `10.10.10.20` | `10.10.10.10` |

No default gateway is required for the isolated lab network. The workstation uses the domain controller as its DNS server so it can discover Active Directory services.
