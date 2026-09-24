# User Offboarding Automation

## Objective

Automate a repeatable Active Directory offboarding workflow that disables an account, removes explicit access groups, moves the account to a dedicated Disabled Users OU, and verifies the final state.

The workflow is implemented in:

```text
scripts/Disable-LabUser.ps1
```

## Capabilities

The script supports:

```text
-Username
-Credential
-Server
-WhatIf
```

It:

1. retrieves the target user
2. inspects current group memberships
3. refuses protected privileged-group targets
4. verifies the Disabled Users OU
5. displays explicit group memberships that will be removed
6. disables the account
7. removes explicit non-default memberships
8. moves the account to `Disabled Users`
9. records the offboarding date in `Description`
10. verifies the final account state and remaining groups

## Original Functional Test

The original offboarding test used `clara.andersen`.

The resulting state was:

```text
Enabled: False
Description: Offboarded 2026-09-23
OU: Disabled Users
Groups: Domain Users
```

A fresh workstation sign-in was rejected with the expected disabled-account message.

## Delegated Administration Test

A second manual lifecycle test used the delegated helpdesk account `alex.helpdesk` to offboard `nora.larsen` without Domain Admin membership.

The helpdesk account successfully disabled the user, removed `GG-HR`, moved the account, and updated the Description field.

## Safe Script Test

The hardened script was tested with `maja.nielsen`.

A preview run used:

```powershell
.\Disable-LabUser.ps1 `
  -Username "maja.nielsen" `
  -Credential $cred `
  -Server "LAB-DC01.corp.lucalab.test" `
  -WhatIf
```

The script displayed all planned changes but did not modify the account.

The real run then required confirmation for each destructive operation and completed successfully.

Final verification:

```text
Enabled: False
Description: Offboarded 2026-09-24
OU: Disabled Users
Groups: Domain Users
```

## Protected Accounts

The script refuses the generic offboarding path if the target is a member of:

```text
Domain Admins
Enterprise Admins
Schema Admins
Administrators
```

## Operational Note

Disabling an AD account prevents new authentication, but an already-active session is a separate consideration. The lab verifies disabled-account behavior with a fresh sign-in attempt.

See also:

- [Delegated helpdesk administration](delegated-helpdesk-administration.md)
- [PowerShell automation safety](powershell-automation-safety.md)

## Skills Demonstrated

- Active Directory account lifecycle management
- PowerShell automation
- group membership cleanup
- OU management
- AD object movement
- delegated least-privilege administration
- `SupportsShouldProcess`
- `-WhatIf` and confirmation controls
- privileged-account safeguards
- post-change verification
