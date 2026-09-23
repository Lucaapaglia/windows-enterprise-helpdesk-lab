# Ticket 003 — User Group Policies Not Applying

## Reported Issue

User-targeted Group Policies were linked to the correct Active Directory OU but were not applying to a domain user.

The user could authenticate normally, but the expected user baseline and policy-driven configuration were missing.

## Symptoms

Running:

```powershell
gpresult /scope user /r
```

showed:

```text
Applied Group Policy Objects
-----------------------------
N/A
```

The expected screen-saver policy registry path was also absent.

## Investigation

Emma Jensen's Active Directory location was correct:

```text
CN=Emma Jensen,OU=Finance,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

The GPO links on the parent Users OU were checked:

```powershell
(Get-GPInheritance -Target "OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test").GpoLinks |
    Format-Table DisplayName,Enabled,Enforced,Order
```

The expected links were present:

```text
GPO-User-Baseline
GPO-Department-Drive-Mapping
```

Inheritance on the Finance OU was not blocked, and both GPOs were inherited correctly.

The GPO status was then checked.

## Root Cause

The GPOs had been configured with **User Configuration disabled**.

The links and OU inheritance were correct, but Windows ignored the user-side settings because that half of the GPO was disabled.

## Resolution

The GPO status was changed so that:

```text
User Configuration: Enabled
Computer Configuration: Disabled
```

for the user-only GPOs.

Group Policy was refreshed:

```powershell
gpupdate /force
```

The user then signed out and signed back in.

## Verification

```powershell
gpresult /scope user /r
```

showed the expected user GPOs.

The screen-saver policy applied successfully, and department drive mappings continued to work according to the user's security-group membership.

## Skills Demonstrated

- Group Policy Management
- GPO Status
- GPO linking and inheritance
- User vs. computer policy scope
- `gpresult`
- `Get-GPInheritance`
- PowerShell
- Structured Windows troubleshooting
