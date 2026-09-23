# Ticket 001 — Finance User Cannot Access Department Share

## User

Oliver Nielsen — Finance

## Reported Issue

User cannot access:

`\\LAB-DC01\Finance`

The user receives an "Access is denied" error.

## Initial Checks

Verified network connectivity:

```powershell
ping LAB-DC01

Verified domain identity:

whoami

Checked current security groups:

whoami /groups
Investigation

The Finance share uses group-based access:

GG-Finance
→ DL-Finance-RW
→ Finance share

Oliver Nielsen was not a member of GG-Finance.

## Root Cause

Incorrect Active Directory group membership.

## Resolution

Added the user back to the Finance security group:

Add-ADGroupMember "GG-Finance" -Members "oliver.nielsen"

The user signed out and signed back in so that Windows could obtain
a new security token containing the updated group membership.

## Verification

The user successfully accessed:

\\LAB-DC01\Finance

and created a test file.