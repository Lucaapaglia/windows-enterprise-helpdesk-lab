# Active Directory Structure

The lab uses an OU structure designed to separate users, computers, and security groups for easier administration and future Group Policy application.

## Organizational Units

```text
corp.lucalab.test
└── Copenhagen
    ├── Users
    │   ├── Finance
    │   ├── HR
    │   ├── Sales
    │   └── IT
    ├── Computers
    └── Groups
```

Department users are placed in the matching departmental OU. Domain-joined workstations are placed in `Copenhagen\Computers` so computer-targeted Group Policy can be scoped cleanly.

## Security Groups

The initial department global security groups are:

- `GG-Finance`
- `GG-HR`
- `GG-Sales`
- `GG-IT`

These global groups represent department membership and provide a consistent way to assign access to shared resources and future policies.

## Example Distinguished Name

A Finance user stored in the Finance OU has a distinguished name in this form:

```text
CN=Emma Jensen,OU=Finance,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test
```

The OU structure will later support Group Policy scoping, delegated administration, and group-based file permissions.
