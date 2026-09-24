# Delegated Helpdesk Administration

## Objective

Demonstrate least-privilege Active Directory administration by allowing a normal helpdesk operator to perform employee onboarding and offboarding tasks without membership in Domain Admins, Enterprise Admins, or the built-in Administrators group.

## Helpdesk Security Group

A dedicated global security group was created:

```text
GG-Helpdesk-Admins
```

A normal IT user was added to the group:

```text
alex.helpdesk
```

Verified group membership:

```text
Domain Users
GG-IT
GG-Helpdesk-Admins
```

The account was not added to:

```text
Domain Admins
Enterprise Admins
Administrators
```

## Delegated Scope

Permissions were delegated in Active Directory Users and Computers.

The helpdesk group received scoped user-account management rights below:

```text
OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

Delegation was also applied to the Groups OU so the operator could modify department membership for:

```text
GG-Finance
GG-HR
GG-Sales
GG-IT
```

## Manual Delegation Verification

Using an explicit credential:

```powershell
$cred = Get-Credential CORP\alex.helpdesk
```

the helpdesk operator successfully created `nora.larsen` in the HR OU and added the user to `GG-HR`.

The same credential then successfully:

- disabled `nora.larsen`
- removed `GG-HR`
- moved the user to `Disabled Users`
- updated the offboarding description

The account remained outside privileged domain-administration groups throughout the test.

## Scripted Delegation Verification

The hardened lifecycle scripts were then tested with the same delegated credential and an explicit server:

```text
LAB-DC01.corp.lucalab.test
```

A Sales lifecycle was tested with `maja.nielsen`.

Onboarding `-WhatIf` previewed creation and group assignment without changing AD.

The real onboarding run verified:

```text
Enabled: True
Department: Sales
Groups: Domain Users, GG-Sales
```

Offboarding `-WhatIf` previewed account disablement, group removal, movement, and description update without changing the account.

The confirmed real offboarding run verified:

```text
Enabled: False
Description: Offboarded 2026-09-24
OU: Disabled Users
Groups: Domain Users
```

## Security Result

The lab now demonstrates both manual and scripted lifecycle administration under delegated permissions.

Routine user management does not require Domain Admin membership, and the scripts support explicit credentials, explicit domain-controller targeting, preview mode, confirmation controls, and post-change verification.

See [PowerShell automation safety](powershell-automation-safety.md).

## Skills Demonstrated

- Active Directory delegation of control
- least-privilege administration
- scoped OU permissions
- delegated group membership management
- PowerShell credential handling
- explicit domain-controller targeting
- `SupportsShouldProcess` and `-WhatIf`
- lifecycle administration
- verification of privilege boundaries
