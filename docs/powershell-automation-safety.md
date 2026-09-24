# PowerShell Automation Safety

## Objective

Harden the lab's user-lifecycle scripts so routine onboarding and offboarding can be previewed, executed with delegated credentials, and verified against a specific domain controller.

## Common Parameters

Both scripts support:

```text
-Credential
-Server
-WhatIf
```

This allows the operator to use the delegated helpdesk account explicitly instead of relying on the current PowerShell session identity.

Example:

```powershell
$cred = Get-Credential CORP\alex.helpdesk
```

The lab uses:

```text
LAB-DC01.corp.lucalab.test
```

as the explicit server during delegated tests.

## Onboarding Preview

The onboarding script was tested with:

```powershell
.\New-LabUser.ps1 `
  -FirstName "Maja" `
  -LastName "Nielsen" `
  -Department "Sales" `
  -Credential $cred `
  -Server "LAB-DC01.corp.lucalab.test" `
  -WhatIf
```

The preview reported the two intended operations:

```text
Create Active Directory user
Add user to department group
```

The script did not request a password and did not create the account.

A follow-up query for `maja.nielsen` returned no object.

## Real Onboarding

The same command was then run without `-WhatIf`.

The script successfully:

- created `maja.nielsen`
- placed the user in the Sales OU
- added the user to `GG-Sales`
- verified that the account was enabled
- verified the final department and group membership

Verified output included:

```text
Enabled: True
Department: Sales
OU: CN=Maja Nielsen,OU=Sales,OU=Users,OU=Copenhagen,...
Groups: Domain Users, GG-Sales
```

## Offboarding Preview

The offboarding script was run with:

```powershell
.\Disable-LabUser.ps1 `
  -Username "maja.nielsen" `
  -Credential $cred `
  -Server "LAB-DC01.corp.lucalab.test" `
  -WhatIf
```

The preview showed all planned changes:

- disable the AD account
- remove `GG-Sales`
- move the account to `Disabled Users`
- set the offboarding description

No change was made during the preview.

## Real Offboarding

The real offboarding run used confirmation prompts before each destructive action.

The script successfully:

- disabled `maja.nielsen`
- removed `GG-Sales`
- moved the account to `Disabled Users`
- set `Description` to `Offboarded 2026-09-24`

Final verification showed:

```text
Enabled: False
Description: Offboarded 2026-09-24
OU: CN=Maja Nielsen,OU=Disabled Users,OU=Users,OU=Copenhagen,...
Groups: Domain Users
```

## Protected-Account Check

The offboarding script checks group membership before making changes and refuses to proceed when the target is a member of one of these privileged groups:

```text
Domain Admins
Enterprise Admins
Schema Admins
Administrators
```

This reduces the risk of using the generic offboarding workflow against a privileged administrative account.

## Deterministic Verification

When testing delegated operations, verification should use the same `-Credential` and `-Server` parameters used for the change.

Example:

```powershell
Get-ADPrincipalGroupMembership maja.nielsen `
  -Credential $cred `
  -Server LAB-DC01.corp.lucalab.test
```

This keeps the operation and verification in the same authentication and server context.

## Skills Demonstrated

- advanced PowerShell functions
- `SupportsShouldProcess`
- `-WhatIf`
- confirmation controls
- reusable splatted AD parameters
- explicit credential handling
- explicit domain-controller targeting
- privileged-account safeguards
- post-change verification
- delegated least-privilege automation
