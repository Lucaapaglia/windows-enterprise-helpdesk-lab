# Ticket 001 · Finance user gets “Access is denied”

Oliver Nielsen, a Finance test user, could reach `LAB-DC01` but could not open `\\LAB-DC01\Finance`. File Explorer returned “Access is denied.”

## Investigation

From the user's Windows session, I checked the server connection, the signed-in account and the groups in the current sign-in token.

```powershell
ping LAB-DC01
whoami
whoami /groups
```

The share grants access through `DL-Finance-RW`. Members of `GG-Finance` receive that access because the Finance group is nested inside `DL-Finance-RW`. Oliver's account was missing from `GG-Finance`.

## Resolution

I restored the lab user's Finance membership. The existing share and NTFS permissions already granted the intended access to the department group.

```powershell
Add-ADGroupMember -Identity 'GG-Finance' -Members 'oliver.nielsen'
```

The user signed out of Windows and signed back in so the new session picked up the group change.

## Closure check

From the fresh user session, Oliver opened `\\LAB-DC01\Finance` and created a test file. That confirmed both folder access and the ability to write under the user's own account.

[Share and NTFS configuration](../docs/file-sharing-and-permissions.md) · [Employee guide for a missing Finance drive](../docs/finance-drive-help.md)
