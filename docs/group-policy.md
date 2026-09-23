# Group Policy Configuration

## Objective

Use Group Policy to centrally manage the Windows 11 workstation and automatically map department network drives according to Active Directory group membership.

## Final OU Structure

```text
corp.lucalab.test
├── Domain Controllers
│   └── LAB-DC01
└── Copenhagen
    ├── Computers
    │   └── LAB-PC01
    ├── Groups
    └── Users
        ├── Finance
        ├── HR
        ├── IT
        └── Sales
```

## GPO Design

Three GPOs are used:

### GPO-Workstation-Baseline

Linked to:

```text
Copenhagen\Computers
```

Purpose:

- computer-side workstation configuration
- centralized baseline settings for domain-joined clients

Configured setting:

```text
Computer Configuration
→ Policies
→ Administrative Templates
→ System
→ Logon
→ Always wait for the network at computer startup and logon
→ Enabled
```

The GPO is configured as computer-side only.

### GPO-User-Baseline

Linked to:

```text
Copenhagen\Users
```

Purpose:

- common user-session settings

Configured settings:

```text
User Configuration
→ Policies
→ Administrative Templates
→ Control Panel
→ Personalization
```

- Enable screen saver: Enabled
- Password protect the screen saver: Enabled
- Screen saver timeout: 900 seconds

The GPO is configured with user settings enabled and computer settings disabled.

### GPO-Department-Drive-Mapping

Linked to:

```text
Copenhagen\Users
```

Purpose:

- automatically map department shares according to security-group membership

Mappings:

| Group | Drive | Share |
|---|---:|---|
| `GG-Finance` | `F:` | `\\LAB-DC01\Finance` |
| `GG-HR` | `H:` | `\\LAB-DC01\HR` |
| `GG-Sales` | `S:` | `\\LAB-DC01\Sales` |
| Domain users | `P:` | `\\LAB-DC01\Public` |

The department mappings use Group Policy Preferences with item-level targeting based on the relevant AD security group.

## Example: Finance User

A Finance user such as Emma Jensen is a member of:

```text
GG-Finance
```

After user Group Policy processing, the workstation maps:

```text
F: → \\LAB-DC01\Finance
P: → \\LAB-DC01\Public
```

The user does not receive the HR or Sales mappings.

## Verification

User-side policy processing:

```powershell
gpupdate /force
gpresult /scope user /r
net use
```

Expected applied user GPOs:

```text
GPO-User-Baseline
GPO-Department-Drive-Mapping
```

Computer-side policy processing is checked from an elevated shell:

```powershell
gpresult /scope computer /r
```

Expected computer GPO:

```text
GPO-Workstation-Baseline
```

The screen-saver policy can also be verified in the current user's registry:

```powershell
Get-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop"
```

Expected values include:

```text
ScreenSaveActive    = 1
ScreenSaverIsSecure = 1
ScreenSaveTimeOut   = 900
```

## Troubleshooting Lessons

Two real configuration issues were encountered while implementing Group Policy:

1. The `Copenhagen` OU had originally been created beneath the built-in `Domain Controllers` OU. This caused `LAB-PC01` to inherit Domain Controller security policy and prevented a normal domain user from logging on interactively.
2. The user GPOs were linked correctly but their user side was disabled through GPO Status. `gpresult` therefore showed no applied user GPOs until User Configuration was re-enabled.

Both incidents are documented separately in the `tickets/` directory.

## Skills Demonstrated

- Group Policy Management
- GPO linking and inheritance
- User vs. computer policy scope
- Group Policy Preferences
- Item-level targeting
- Automatic network drive mapping
- RSOP / `gpresult`
- Windows security policy troubleshooting
- Active Directory OU design
