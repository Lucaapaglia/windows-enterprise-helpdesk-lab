# Active Directory Structure

The lab uses an OU structure designed to separate users, computers, and security groups for easier administration, Group Policy scoping, account lifecycle management, and delegated support administration.

## Organizational Units

```text
corp.lucalab.test
├── Domain Controllers
│   └── LAB-DC01
└── Copenhagen
    ├── Users
    │   ├── Disabled Users
    │   ├── Finance
    │   ├── HR
    │   ├── Sales
    │   └── IT
    ├── Computers
    │   └── LAB-PC01
    └── Groups
```

Department users are placed in the matching departmental OU. Domain-joined workstations are placed in `Copenhagen\Computers` so computer-targeted Group Policy can be scoped cleanly.

Accounts that complete the lab offboarding workflow are disabled and moved into:

```text
OU=Disabled Users,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

The Disabled Users OU is protected from accidental deletion.

## Security Groups

Department membership is represented by:

- `GG-Finance`
- `GG-HR`
- `GG-Sales`
- `GG-IT`

Delegated helpdesk administration uses:

- `GG-Helpdesk-Admins`

The helpdesk group is used for scoped user-management and department-group administration rather than broad Domain Admin membership.

Resource-access groups such as `DL-Finance-RW` are used as part of the AGDLP-style permissions model documented in the file-sharing section.

## Example Distinguished Names

Active Finance user:

```text
CN=Emma Jensen,OU=Finance,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

Offboarded user:

```text
CN=Nora Larsen,OU=Disabled Users,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

This structure supports Group Policy scoping, group-based file permissions, onboarding/offboarding automation, and delegated least-privilege helpdesk administration.
