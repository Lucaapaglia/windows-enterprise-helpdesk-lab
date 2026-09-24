# User Onboarding Automation

## Objective

Automate a repeatable Active Directory onboarding workflow and verify that a newly created employee receives the correct identity, Group Policy, drive mappings, and file permissions.

The workflow is implemented in:

```text
scripts/New-LabUser.ps1
```

## Capabilities

The script accepts first name, last name, and department, with supported departments restricted to:

```text
Finance
HR
Sales
IT
```

It also supports:

```text
-Credential
-Server
-WhatIf
```

For a valid employee, the script:

1. builds a `firstname.lastname` username
2. generates the domain UPN
3. validates the target department
4. verifies the target OU
5. verifies the matching department group
6. checks for duplicate usernames
7. creates the enabled AD account
8. requires a password change at first logon
9. assigns the matching `GG-Department` group
10. verifies the final account state and group memberships

## Functional Validation

The original end-to-end Finance test used `clara.andersen`.

The account successfully:

- authenticated to `LAB-PC01`
- received `GPO-User-Baseline`
- received `GPO-Department-Drive-Mapping`
- received `F:` and `P:`
- created, read, and deleted a file on Finance
- received Access Denied against the Sales share

The script also rejected:

- a duplicate `clara.andersen` account
- an unsupported `Marketing` department

## Delegated and Safe Execution

The hardened script was tested with the delegated helpdesk credential:

```powershell
$cred = Get-Credential CORP\alex.helpdesk
```

A Sales user was previewed first:

```powershell
.\New-LabUser.ps1 `
  -FirstName "Maja" `
  -LastName "Nielsen" `
  -Department "Sales" `
  -Credential $cred `
  -Server "LAB-DC01.corp.lucalab.test" `
  -WhatIf
```

The preview showed the intended account creation and group assignment without creating anything.

The real run then created `maja.nielsen` and verified:

```text
Enabled: True
Department: Sales
Groups: Domain Users, GG-Sales
```

This confirms that the production-style onboarding path works with delegated permissions and explicit domain-controller targeting.

See also:

- [Delegated helpdesk administration](delegated-helpdesk-administration.md)
- [PowerShell automation safety](powershell-automation-safety.md)

## Skills Demonstrated

- PowerShell parameter validation
- Active Directory user provisioning
- OU targeting
- duplicate-account checks
- AD security-group assignment
- first-logon password change
- Group Policy verification
- SMB and NTFS authorization testing
- `SupportsShouldProcess` and `-WhatIf`
- delegated credential handling
- post-change verification
