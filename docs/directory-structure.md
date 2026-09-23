# Active Directory Structure

The lab uses an OU structure designed to separate users, computers, and security groups for easier administration, Group Policy scoping, and account lifecycle management.

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

The department global security groups are:

- `GG-Finance`
- `GG-HR`
- `GG-Sales`
- `GG-IT`

These global groups represent department membership and provide a consistent way to assign access to shared resources and policies.

Resource-access groups such as `DL-Finance-RW` are used as part of the AGDLP-style permissions model documented in the file-sharing section.

## Example Distinguished Names

Active Finance user:

```text
CN=Emma Jensen,OU=Finance,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

Offboarded user:

```text
CN=Clara Andersen,OU=Disabled Users,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

This structure supports Group Policy scoping, group-based file permissions, onboarding/offboarding automation, and future delegated helpdesk administration.
