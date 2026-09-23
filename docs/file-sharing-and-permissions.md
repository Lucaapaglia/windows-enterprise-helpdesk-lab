# File Sharing and Permissions

## Objective

Configure centralized department file shares on `LAB-DC01` and control access using Active Directory security groups, SMB share permissions, and NTFS permissions.

## Environment

| Component | Value |
|---|---|
| Domain | `corp.lucalab.test` |
| Domain Controller / File Server | `LAB-DC01` |
| Workstation | `LAB-PC01` |
| Server IP | `10.10.10.10` |
| Client IP | `10.10.10.20` |

## Folder and Share Structure

Department data is stored under:

```text
C:\CompanyData
├── Finance
├── HR
├── Sales
└── Public
```

The folders are exposed as SMB shares:

```text
\\LAB-DC01\Finance
\\LAB-DC01\HR
\\LAB-DC01\Sales
\\LAB-DC01\Public
```

## Group-Based Access Model

Department membership is represented by global security groups:

- `GG-Finance`
- `GG-HR`
- `GG-Sales`
- `GG-IT`

Resource permissions use domain-local groups:

- `DL-Finance-RW`
- `DL-HR-RW`
- `DL-Sales-RW`

The access model follows AGDLP:

```text
Accounts
  ↓
Global Groups
  ↓
Domain Local Groups
  ↓
Permissions
```

Example:

```text
Emma Jensen
  ↓
GG-Finance
  ↓
DL-Finance-RW
  ↓
\\LAB-DC01\Finance
```

This separates user membership from resource permissions and makes access easier to manage.

## NTFS Permissions

Department folders grant `Modify` access to the matching resource group while retaining administrative access for SYSTEM and Administrators.

| Folder | Principal | Permission |
|---|---|---|
| Finance | `CORP\DL-Finance-RW` | Modify |
| HR | `CORP\DL-HR-RW` | Modify |
| Sales | `CORP\DL-Sales-RW` | Modify |
| Public | `CORP\Domain Users` | Modify |

Using `Modify` allows normal users to create, edit, read, and delete files without granting permission to arbitrarily change ownership or ACLs.

## SMB Permissions

The SMB shares are configured so that the matching department resource group has Change/Read access, while Domain Admins retain Full Control.

Example Finance share:

```text
\\LAB-DC01\Finance

CORP\DL-Finance-RW  → Change + Read
CORP\Domain Admins  → Full Control
```

## Verification

Server-side verification commands:

```powershell
Get-SmbShare
Get-SmbShareAccess -Name Finance
Get-Acl "C:\CompanyData\Finance" | Format-List
Get-ADGroupMember "DL-Finance-RW"
```

Client-side access was tested using normal domain accounts. Finance users can access the Finance share but are denied access to Sales resources, while Sales users can access Sales but not Finance.

The Public share is accessible to normal domain users.

## Manual Drive Mapping Test

Before automating drive mappings with Group Policy, a department share was mapped manually:

```powershell
net use F: \\LAB-DC01\Finance /persistent:yes
net use
net use F: /delete
```

This established a working SMB and permissions baseline before GPO automation.

## Skills Demonstrated

- Active Directory security groups
- AGDLP access-control design
- SMB file sharing
- NTFS permissions
- Least-privilege access control
- Windows domain authentication
- Network drive mapping
- PowerShell administration
- Access troubleshooting
