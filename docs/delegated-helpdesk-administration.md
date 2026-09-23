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

### User Administration

Delegation was applied to:

```text
OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

The helpdesk group received the ability to manage user accounts within the user hierarchy, including the departmental OUs and Disabled Users OU.

### Department Group Membership

Delegation was also applied to the Groups OU so the helpdesk operator could modify department group membership.

The relevant department groups are:

```text
GG-Finance
GG-HR
GG-Sales
GG-IT
```

## Credential Test

The delegated account was used explicitly from an administrative PowerShell session:

```powershell
$cred = Get-Credential CORP\alex.helpdesk
```

A basic directory read confirmed that the credentials were valid:

```powershell
Get-ADUser emma.jensen `
  -Credential $cred `
  -Server LAB-DC01.corp.lucalab.test
```

## Onboarding Test

Using only the delegated helpdesk credentials, a new HR user was created:

```text
nora.larsen
```

The account was placed in:

```text
OU=HR,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

The delegated operator then added the user to:

```text
GG-HR
```

Verification showed:

```text
Enabled: True
Department: HR

Group memberships:
- Domain Users
- GG-HR
```

## Offboarding Test

The same delegated credentials were then used to offboard the test account.

The helpdesk operator successfully:

1. disabled `nora.larsen`
2. removed `GG-HR`
3. moved the account to the Disabled Users OU
4. updated the Description field with the offboarding date

Final verification:

```text
Enabled: False
Description: Offboarded 2026-09-23
OU: Disabled Users

Group memberships:
- Domain Users
```

## Security Result

The full create → group assignment → disable → group removal → move workflow succeeded with the delegated helpdesk account while the operator remained outside privileged domain administration groups.

This demonstrates a more realistic support model than performing routine user lifecycle tasks with Domain Admin credentials.

## Skills Demonstrated

- Active Directory delegation of control
- least-privilege administration
- scoped OU permissions
- delegated group membership management
- PowerShell credential handling
- user lifecycle administration
- verification of privilege boundaries
