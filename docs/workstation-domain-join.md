# Windows Workstation Domain Join

## Workstation

- Hostname: `LAB-PC01`
- OS: Windows 11 Enterprise
- IPv4: `10.10.10.20`
- DNS: `10.10.10.10`
- Domain: `corp.lucalab.test`

## Pre-Join Verification

The workstation was tested using:

- `ping`
- `nslookup`
- `Resolve-DnsName`
- `nltest /dsgetdc`

## Domain Join

```powershell
Add-Computer `
  -DomainName "corp.lucalab.test" `
  -Credential "CORP\Administrator" `
  -Restart