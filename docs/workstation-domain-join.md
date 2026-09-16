# Windows Workstation Domain Join

## Workstation

- Hostname: `LAB-PC01`
- OS: Windows 11 Enterprise
- IPv4: `10.10.10.20`
- DNS server: `10.10.10.10`
- Domain: `corp.lucalab.test`

## Pre-Join Verification

Before joining the workstation to the domain, connectivity, DNS resolution, and domain-controller discovery were tested using:

```powershell
ping 10.10.10.10
nslookup corp.lucalab.test
Resolve-DnsName corp.lucalab.test
nltest /dsgetdc:corp.lucalab.test
```

The workstation was configured to use `LAB-DC01` (`10.10.10.10`) as its DNS server so Active Directory service records could be resolved correctly.

## Domain Join

The workstation was joined to the domain using an elevated PowerShell session:

```powershell
Add-Computer `
  -DomainName "corp.lucalab.test" `
  -Credential "CORP\Administrator" `
  -Restart
```

After rebooting, a domain user successfully authenticated on `LAB-PC01`.

## Verification

The domain session was verified with:

```powershell
whoami
echo $env:LOGONSERVER
whoami /groups
gpresult /r
```

The computer account was also verified in Active Directory and placed in:

```text
OU=Computers,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

## Result

`LAB-PC01` is now a domain-joined Windows 11 Enterprise workstation managed through the `corp.lucalab.test` Active Directory environment.
