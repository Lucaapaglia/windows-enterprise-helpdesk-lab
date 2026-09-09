# Active Directory Configuration

## Domain

- Domain: `corp.lucalab.test`
- NetBIOS name: `CORP`
- Domain Controller: `LAB-DC01`
- IP address: `10.10.10.10`

## Installed Roles

- Active Directory Domain Services
- DNS Server

## Purpose

The domain controller provides centralized identity, authentication,
DNS, computer management, and policy management for the lab environment.

## Verification

The environment was verified using:

- `Get-ADDomain`
- `Get-ADForest`
- `Resolve-DnsName`
- `dcdiag /test:dns`