# Active Directory Structure

The lab uses an OU structure designed to separate users,
computers, and security groups for easier administration and
future Group Policy application.

## Organizational Units

corp.lucalab.test
└── Copenhagen
    ├── Users
    │   ├── Finance
    │   ├── HR
    │   ├── Sales
    │   └── IT
    ├── Computers
    └── Groups

## Security Groups

- GG-Finance
- GG-HR
- GG-Sales
- GG-IT

Global security groups are used to represent department
membership and will later be used to assign access to shared
resources.