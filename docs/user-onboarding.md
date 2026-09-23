# User Onboarding Automation

## Objective

Automate a repeatable Active Directory onboarding workflow and verify that a newly created employee receives the correct identity, Group Policy, drive mappings, and file permissions.

The workflow is implemented in:

```text
scripts/New-LabUser.ps1
```

## What the Script Does

The script accepts:

- first name
- last name
- department

Supported departments are restricted with PowerShell `ValidateSet`:

```text
Finance
HR
Sales
IT
```

For a valid employee, the script:

1. builds a username in `firstname.lastname` format
2. generates the UPN `username@corp.lucalab.test`
3. selects the matching departmental OU
4. verifies that the OU exists
5. verifies that the matching `GG-Department` security group exists
6. checks for duplicate usernames
7. creates the enabled AD user
8. requires a password change at first logon
9. adds the user to the correct department security group

The script reports user creation and group assignment as separate steps so that a partial onboarding failure is easier to identify.

## Example

```powershell
.\New-LabUser.ps1 `
  -FirstName "Clara" `
  -LastName "Andersen" `
  -Department "Finance"
```

The expected identity is:

```text
Username: clara.andersen
UPN: clara.andersen@corp.lucalab.test
OU: OU=Finance,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
Group: GG-Finance
```

## Validation Tests

### Duplicate account protection

The script was run a second time for `clara.andersen`.

The script stopped before creating another account and returned:

```text
User 'clara.andersen' already exists.
```

### Department validation

The script was tested with:

```powershell
.\New-LabUser.ps1 `
  -FirstName "Test" `
  -LastName "Person" `
  -Department "Marketing"
```

PowerShell rejected the value because `Marketing` is not part of the allowed department set.

No account was created.

## End-to-End Verification

The test employee `CORP\clara.andersen` was created in the Finance OU and became a member of:

```text
Domain Users
GG-Finance
```

The user successfully authenticated to `LAB-PC01`.

User-side RSOP showed:

```text
GPO-User-Baseline
GPO-Department-Drive-Mapping
```

The Finance and Public drives were automatically mapped:

```text
F: -> \\LAB-DC01\Finance
P: -> \\LAB-DC01\Public
```

The user was able to create, read, and remove a test file on the Finance share:

```powershell
Set-Content F:\clara-test.txt "Finance access test"
Get-Content F:\clara-test.txt
Remove-Item F:\clara-test.txt
```

Access to the Sales share was denied:

```powershell
Get-ChildItem \\LAB-DC01\Sales
```

This confirms that onboarding integrates correctly with the existing AD group, GPO, SMB, and NTFS design.

## Delegated Administration Verification

A separate least-privilege test was performed with:

```text
CORP\alex.helpdesk
```

The account was a member of `GG-Helpdesk-Admins` but not Domain Admins.

Using explicitly supplied helpdesk credentials, the operator successfully created `nora.larsen` in the HR OU and added the account to `GG-HR`.

This verifies that routine onboarding can be completed through delegated AD permissions rather than broad domain-administrator access.

See [Delegated helpdesk administration](delegated-helpdesk-administration.md).

## Skills Demonstrated

- PowerShell parameter validation
- Active Directory user provisioning
- OU targeting
- duplicate-account checks
- AD security-group assignment
- first-logon password change
- Group Policy verification
- network drive mapping
- SMB and NTFS authorization testing
- least-privilege administration
- end-to-end troubleshooting
