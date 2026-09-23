# User Offboarding Automation

## Objective

Document the tested Active Directory offboarding workflow used in the lab.

The workflow is implemented in:

```text
scripts/Disable-LabUser.ps1
```

## Disabled Users OU

The lab includes:

```text
OU=Disabled Users,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

This OU is protected from accidental deletion.

## Workflow

The script is run with a username:

```powershell
.\Disable-LabUser.ps1 -Username "clara.andersen"
```

It performs these tasks:

1. locates the AD user
2. checks that the Disabled Users OU exists
3. disables the account
4. removes explicit group memberships
5. moves the account to the Disabled Users OU
6. adds an offboarding date to the Description field

The user's default `Domain Users` membership remains.

## Test Result

The workflow was tested with the Finance user `clara.andersen`.

Before the test, the account was enabled and belonged to:

```text
Domain Users
GG-Finance
```

The script reported:

```text
[OK] Account disabled
[OK] Removed from GG-Finance
[OK] Account moved
```

Verification showed:

```text
Enabled: False
Description: Offboarded 2026-09-23
OU: Disabled Users
```

Only `Domain Users` remained.

## Sign-in Verification

After signing out of `LAB-PC01`, a new sign-in attempt was made using the disabled account.

Windows displayed:

```text
Your account has been disabled. Please see your system administrator.
```

This confirmed the expected disabled-account behavior for a new workstation sign-in.

## Delegated Administration Verification

A second offboarding test was performed with the delegated helpdesk account `alex.helpdesk`.

Using the helpdesk credential, the operator successfully:

- disabled `nora.larsen`
- removed `GG-HR`
- moved the account to `Disabled Users`
- updated the Description field

Final state:

```text
Enabled: False
Description: Offboarded 2026-09-23
Group memberships:
- Domain Users
```

The helpdesk account remained outside Domain Admins, Enterprise Admins, and Administrators.

See [Delegated helpdesk administration](delegated-helpdesk-administration.md).

## Operational Note

A disabled AD account blocks new authentication, but an already-active session is a separate consideration. In this lab, the user was signed out before the new sign-in test.

## Skills Demonstrated

- Active Directory account lifecycle management
- PowerShell automation
- group membership cleanup
- OU management
- AD object movement
- delegated least-privilege administration
- post-change verification
- technical documentation
