# Ticket 004 — Workstation GPO Computer Settings Disabled

## Reported Issue

A newly onboarded Finance user was unable to complete the expected workstation sign-in workflow, and computer-side Group Policy was not applying to `LAB-PC01`.

## Investigation

Computer RSOP was checked from an elevated PowerShell session:

```powershell
gpresult /scope computer /r
```

Before the fix, the only applied domain GPO shown was:

```text
Default Domain Policy
```

The expected policy was missing:

```text
GPO-Workstation-Baseline
```

The GPO status was checked:

```powershell
Get-GPO -Name "GPO-Workstation-Baseline" |
    Select-Object DisplayName,GpoStatus
```

It showed:

```text
ComputerSettingsDisabled
```

## Root Cause

The workstation baseline was a computer-targeted GPO, but its Computer Configuration side had been disabled through GPO Status.

The GPO link and workstation OU placement were correct, but the settings inside the computer half of the GPO could not be processed while that half was disabled.

## Resolution

The GPO status was corrected to:

```text
UserSettingsDisabled
```

This keeps Computer Configuration enabled while disabling the unused User Configuration side.

Group Policy was then refreshed and the workstation was retested.

## Verification

After the correction:

```powershell
gpresult /scope computer /r
```

showed:

```text
GPO-Workstation-Baseline
Default Domain Policy
```

The newly onboarded user was then able to log on to `LAB-PC01` and continue the end-to-end onboarding test.

Because the observed sign-in symptom and the GPO-status correction occurred together, this ticket records the verified configuration fault and recovery without assuming an unobserved lower-level mechanism.

## Skills Demonstrated

- Group Policy Management
- GPO Status
- computer vs. user configuration scope
- RSOP / `gpresult`
- PowerShell
- workstation policy troubleshooting
