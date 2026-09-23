# Ticket 002 — Workstation Inherited Domain Controller Policy

## Reported Issue

A normal domain user could not log on interactively to `LAB-PC01`.

Windows displayed:

> The sign-in method you're trying to use isn't allowed.

## Investigation

The failed logon was inspected in the Windows Security event log.

Event ID `4625` reported:

- Logon Type: `2` — interactive logon
- Status: `0xC000015B`
- Failure reason: the user had not been granted the requested logon type at the workstation

The effective local security policy was exported:

```powershell
secedit /export /cfg C:\secpol.cfg
```

Interactive logon rights were then inspected:

```powershell
Select-String C:\secpol.cfg `
  -Pattern "SeInteractiveLogonRight|SeDenyInteractiveLogonRight"
```

The effective `SeInteractiveLogonRight` contained Domain Controller-oriented operator groups but did not include the standard workstation Users group.

Active Directory inspection showed that the `Copenhagen` OU had accidentally been created beneath the built-in `Domain Controllers` OU.

Incorrect hierarchy:

```text
corp.lucalab.test
└── Domain Controllers
    ├── LAB-DC01
    └── Copenhagen
        └── Computers
            └── LAB-PC01
```

## Root Cause

Because `Copenhagen` was a child of `Domain Controllers`, the Windows 11 workstation inherited security policy intended for domain controllers.

That policy changed the effective interactive-logon rights on `LAB-PC01`, causing normal domain-user logon to fail.

## Resolution

The `Copenhagen` OU was moved to the domain root.

Correct hierarchy:

```text
corp.lucalab.test
├── Domain Controllers
│   └── LAB-DC01
└── Copenhagen
    └── Computers
        └── LAB-PC01
```

The workstation's final location was verified with:

```powershell
Get-ADComputer LAB-PC01 |
    Select-Object DistinguishedName
```

Expected distinguished name:

```text
CN=LAB-PC01,OU=Computers,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

After the workstation was restarted and policy was reprocessed, normal domain-user logon succeeded.

## Result

`CORP\emma.jensen` was able to log on successfully to `LAB-PC01`.

## Skills Demonstrated

- Active Directory OU design
- GPO inheritance
- Windows Security Event Log analysis
- Event ID 4625
- Windows user-rights troubleshooting
- SID and security-policy investigation
- PowerShell
- Root-cause analysis
